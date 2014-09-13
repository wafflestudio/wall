package services.chat

import scala.concurrent.duration._
import akka.actor._
import akka.pattern.ask
import akka.util.Timeout
import models.ChatLog
import models.ChatRoom
import models.User
import play.api.Logger
import play.api.libs.concurrent._
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.iteratee._
import play.api.libs.json._
import utils.UsageSet
import scala.concurrent.Future
import services.ConnectionInfo
import services.Connection

class ChatCoreActor(roomId: String, roomActor: ActorRef) extends Actor {

	implicit val timeout = Timeout(1 second)

	def prevMessages(timestampOpt: Option[Long]) = {
		timestampOpt match {
			case Some(timestamp) =>
				ChatLog.findAllByChatRoom(roomId, timestamp).map(_.frozen)
			case None =>
				ChatLog.findAllByChatRoom(roomId).map(_.frozen)
		}
	}

	def prevMessages(startTs: Long, endTs: Long) = {
		ChatLog.findAllByChatRoom(roomId, startTs, endTs).map(_.frozen)
	}

	def saveMessage(kind: String, userId: String, message: String) = {
		val when = System.currentTimeMillis
		(ChatLog.create(kind, roomId, userId, message, when).frozen.timestamp, when)
	}

	def getUserProfile(userId: String) = {
		val user = User.find(userId).map(_.frozen).get
		val email = user.email
		val nickname = user.firstName.get + " " + user.lastName.get
		(email, nickname)
	}

	def getConnections: Future[Map[String, List[Connection]]] = {
		(roomActor ? ListConnections) map {
			case map: Map[String, List[Connection]] =>
				map
		}
	}

	def getNumConnections: Future[Int] = {
		(roomActor ? NumConnections) map {
			case num: Int =>
				num
		}
	}

	def getListUsers: Future[JsValue] = {

		getConnections.map { connections =>
			JsArray(connections.map { connection =>
				val user = User.find(connection._1).map(_.frozen).get

				Json.obj(
					"userId" -> user.id,
					"email" -> user.email,
					"nickname" -> user.firstName.get)

			}.toSeq)
		}

	}

	def receive = {

		case Join(userId, connectionId, timestampOpt) =>
			val kind = "welcome"
			val (email, nickname) = getUserProfile(userId)
			val usersFuture = getListUsers
			val prev = Json.toJson(prevMessages(timestampOpt).map { chatlog => ChatLog.toJson(chatlog) })

			usersFuture.map { users =>
				val respond = Respond(userId, connectionId, Json.obj(
					"kind" -> kind,
					"userId" -> userId,
					"email" -> email,
					"message" -> prev,
					"users" -> users,
					"connectionId" -> connectionId))
				roomActor ! respond
			}

		case NotifyJoin(userId, connectionId) => {
			val kind = "join"
			val (email, nickname) = getUserProfile(userId)
			val text = "has entered"

			val msgFuture = Future(Json.obj(
				"kind" -> kind,
				"userId" -> userId,
				"email" -> email,
				"message" -> text,
				"connectionId" -> connectionId))

			msgFuture.map { msg =>
				val (timestamp, when) = saveMessage(kind, userId, text)
				roomActor ! Broadcast(msg, timestamp, when)
			}
		}

		case Talk(userId, connectionId: Int, text) =>
			val kind = "talk"
			val (email, nickname) = getUserProfile(userId)

			val msgFuture = Future(Json.obj(
				"kind" -> kind,
				"userId" -> userId,
				"email" -> email,
				"message" -> text,
				"connectionId" -> connectionId))

			msgFuture.map { msg =>
				val (timestamp, when) = saveMessage(kind, userId, text)
				roomActor ! Broadcast(msg, timestamp, when)
			}

		case Quit(userId, producer, connectionId) => {
			val kind = "quit"
			val (email, nickname) = getUserProfile(userId)
			ChatRoom.removeUser(roomId, userId)

			val connectionCountForUserFuture = getConnections.map(_.count(_._1 == userId))

			val msgFuture = connectionCountForUserFuture.map { connectionCountForUser =>
				Json.obj(
					"kind" -> kind,
					"userId" -> userId,
					"email" -> email,
					"message" -> Json.obj("numConnections" -> connectionCountForUser).toString)
			}

			msgFuture.map { msg =>
				val (timestamp, when) = saveMessage(kind, userId, (msg \ "message").as[String])
				roomActor ! Broadcast(msg, timestamp, when)
			}

			Logger.info(s"[CHAT] user $userId quit from room $roomId")
		}

	}

}

