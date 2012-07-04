package chat

import play.api.libs.iteratee._
import akka.actor._
import akka.util.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.mvc.Result
import java.util.Date
import java.text.SimpleDateFormat
import java.util.Locale
import play.api.Logger
import play.api.libs.json._
import models.User

case class Join(userId: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Talk(userId: Long, text: String)
case class NotifyJoin(userId: Long)

case class Connected(enumerator: Enumerator[JsValue])
case class CannotConnect(msg: String)

object ChatSystem {

	implicit val timeout = Timeout(1 second)

	lazy val defaultRoom = {
		val roomActor = Akka.system.actorOf(Props[ChatSystem])
		roomActor
	}

	def talk(message: String, userId: Long) = {
		defaultRoom ? Talk(userId, message)
	}

	def establish(userId: Long): Promise[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

		val joinResult = defaultRoom ? Join(userId)

		joinResult.asPromise.map {
			case Connected(producer) =>
				// Create an Iteratee to consume the feed
				val consumer = Iteratee.foreach[JsValue] { event: JsValue =>
					defaultRoom ! Talk(userId, (event \ "text").as[String])
				}.mapDone { _ =>
					defaultRoom ! Quit(userId, producer)
				}

				(consumer, producer)

			case CannotConnect(error) =>

				// Connection error

				// A finished Iteratee sending EOF
				val consumer = Done[JsValue, Unit]((), Input.EOF)

				// Send an error and close the socket
				val producer = Enumerator[JsValue](JsObject(Seq("error" -> JsString(error)))).andThen(Enumerator.enumInput(Input.EOF))

				(consumer, producer)

		}

	}

}

class ChatSystem extends Actor {

	var connections = List.empty[(Long, PushEnumerator[JsValue])]

	def receive = {

		case Join(userId) => {
			// Create an Enumerator to write to this socket
			val producer = Enumerator.imperative[JsValue](onStart = self ! NotifyJoin(userId))
			if (false /* maximum connection per user constraint here*/) {
				sender ! CannotConnect("You have reached your maximum number of connections.")
			}
			else {
				connections = connections :+ (userId, producer)
				sender ! Connected(producer)
			}
		}

		case NotifyJoin(userId) => {
			notifyAll("join", userId, "has entered the room")
		}

		case Talk(userId, text) => {
			notifyAll("talk", userId, text)
		}

		case Quit(userId, producer) => {
			connections = connections.flatMap { p =>
				if(p eq producer)
					None
				else
					Some(p)
			}
			notifyAll("quit", userId, "has left the room")
		}

	}

	def notifyAll(kind: String, userId: Long, text: String) {
		try {
			val username = User.findById(userId).get.email
			
			val msg = JsObject(
				Seq(
					"kind" -> JsString(kind),
					"username" -> JsString(username),
					"message" -> JsString(text),
					"members" -> JsArray(
						connections.map(ws => JsNumber(ws._1))
					)
				)
			)
			connections.foreach {
				case (_, producer) => producer.push(msg)
			}
		}
		catch {
			case _ =>
				// do nothing
		}
	}

}