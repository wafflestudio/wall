package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.libs.iteratee._
import play.api.libs.concurrent._
import akka.actor._
import akka.util.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.Play.current
import models.User

case class Join(userId: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Talk(userId: Long, text: String)
case class NotifyJoin(userId: Long)

case class Connected(enumerator: Enumerator[JsValue])
case class CannotConnect(msg: String)

object WallConnectionManager {
	implicit val timeout = Timeout(1 second)

	lazy val defaultRoom = {
		val roomActor = Akka.system.actorOf(Props[WallActor])
		roomActor
	}
	
	def talk(message: String, userId: Long) = {
		defaultRoom ? Talk(userId, message)
	}

	def establish(wallId: Long, userId: Long): Promise[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

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

class WallActor extends Actor {

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



object Wall extends Controller with Auth {
	def create(name: String) = Action { implicit request =>
		val wallId = models.Wall.create(name)
		Ok(Json.toJson(wallId))
	}

	def sync(wallId: Long) = WebSocket.async[JsValue] { request =>
		request.session.get("current_user_id") match {
			case Some(userId) =>
				WallConnectionManager.establish(wallId, userId.toLong)
			case None =>
				val consumer = Done[JsValue, Unit]((), Input.EOF)
				val producer = Enumerator[JsValue](JsObject(Seq("error" -> JsString("Unauthorized")))).andThen(Enumerator.enumInput(Input.EOF))
				Promise.pure(consumer, producer)
		}
	}

	def delete(id: Long) = AuthenticatedAction { implicit request => 
		models.Wall.delete(id)
		Ok(Json.toJson("OK"))
	}
}