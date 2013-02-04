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
import models.ChatLog
import models.ChatRoom
import java.sql.Timestamp
import collection.mutable.HashMap

case class Join(userId: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Talk(userId: Long, text: String)
case class NotifyJoin(userId: Long)

case class Connected(enumerator: Enumerator[JsValue])
case class CannotConnect(msg: String)

case class Message(kind: String, username: String, text: String)

object ChatSystem {

	implicit val timeout = Timeout(1 second)

	var rooms: Map[Long, ActorRef] = Map()

	def room(roomId: Long): ActorRef = {
		rooms.get(roomId) match {
			case Some(room) => room
			case None =>
				val newRoom = Akka.system.actorOf(Props(new ChatRoomActor(roomId)))
				rooms = rooms + (roomId -> newRoom)
				newRoom
		}
	}

	def establish(roomId: Long, userId: Long, timestamp: Long): Promise[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

		val joinResult = room(roomId) ? Join(userId)

		joinResult.asPromise.map {
			case Connected(producer) =>
				// Create an Iteratee to consume the feed
				val consumer = Iteratee.foreach[JsValue] { event: JsValue =>
					room(roomId) ! Talk(userId, (event \ "text").as[String])
				}.mapDone { _ =>
					room(roomId) ! Quit(userId, producer)
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

class ChatRoomActor(roomId: Long) extends Actor {

	var connections = List.empty[(Long, PushEnumerator[JsValue])]

	def prevMessages(timestamp: Long) = {
		ChatLog.list(roomId, timestamp)
	}

	def logMessage(kind: String, userId: Long, message: String) = {
		ChatLog.create(kind, roomId, userId, message)
	}

	def receive = {

		case Join(userId) => {
			// Create an Enumerator to write to this socket
			val producer = Enumerator.imperative[JsValue](onStart = self ! NotifyJoin(userId))
			val prev = Enumerator(prevMessages(0).map { chatlog => ChatLog.chatlog2Json(chatlog) }: _*)

			if (false /* maximum connection per user constraint here*/ ) {
				sender ! CannotConnect("You have reached your maximum number of connections.")
			}
			else {
				prev.map { jsval => producer.push(jsval) }
				connections = connections :+ (userId, producer)
				ChatRoom.addUser(roomId, userId)
				sender ! Connected(producer)
			}
		}

		case NotifyJoin(userId) => {
      val nickname = User.findById(userId).get.nickname
			notifyAll("join", userId, "has entered")
		}

		case Talk(userId, text) => {
			notifyAll("talk", userId, text)
		}

		case Quit(userId, producer) => {
			connections = connections.flatMap { p =>
				if (p._1 == userId && p._2 == producer)
					None
				else
					Some(p)
			}
			ChatRoom.removeUser(roomId, userId)
			notifyAll("quit", userId, "has left")
		}

	}

	def notifyAll(kind: String, userId: Long, message: String) {

    val user = User.findById(userId)
    val username = user.get.email
    val nickname = user.get.nickname

    val msg = kind match {
      case "talk" => 
        JsObject(Seq(
          "kind" -> JsString(kind),
          "username" -> JsString(username),
          "message" -> JsString(message)))

      case "join" =>
        JsObject( Seq(
          "kind" -> JsString(kind),
          "username" -> JsString(username),
          "nickname" -> JsString(nickname),
          "picture" -> JsString(user.get.picturePath.getOrElse("").replaceFirst("public/", "/assets/")),
          "users" -> JsArray(
            connections.map(i => { 
              val user = User.findById(i._1)
              JsObject(Seq(
                  "email" -> JsString(user.get.email),
                  "nickname" -> JsString(user.get.nickname),
                  "picture" -> JsString(user.get.picturePath.getOrElse("").replaceFirst("public/", "/assets/"))
                  ))}))))

      case "quit" => 
        JsObject( Seq(
          "kind" -> JsString(kind),
          "username" -> JsString(username),
          "users" -> JsArray(
            connections.map(i => { 
              val user = User.findById(i._1)
              JsObject(Seq(
                  "email" -> JsString(user.get.email),
                  "nickname" -> JsString(user.get.nickname),
                  "picture" -> JsString(user.get.picturePath.getOrElse("").replaceFirst("public/", "/assets/"))
                  ))}))))
    }

		logMessage(kind, userId, message)

		connections.foreach {
			case (_, producer) => producer.push(msg)
		}
	}
}
