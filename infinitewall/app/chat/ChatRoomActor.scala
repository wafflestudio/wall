package chat

import play.api.libs.iteratee._
import akka.actor._
import play.api.libs.concurrent.Execution.Implicits._
import scala.concurrent.duration._
import akka.pattern.ask
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
import scala.concurrent.Future
import akka.util.Timeout
import scala.collection.mutable.BitSet
import utils.UsageSet

class ChatRoomActor(roomId: String) extends Actor {

	val connectionUsage = new UsageSet
	case class Connection(enumerator: Enumerator[JsValue], channel: Concurrent.Channel[JsValue], connectionId: Int)
	private var connections = Map.empty[String, List[Connection]]

	def prevMessages(timestampOpt: Option[Long]) = {
		timestampOpt match {
			case Some(timestamp) =>
				ChatLog.list(roomId, timestamp).map(_.frozen)
			case None =>
				ChatLog.list(roomId).map(_.frozen)
		}
	}

	def prevMessages(startTs: Long, endTs: Long) = {
		ChatLog.list(roomId, startTs, endTs).map(_.frozen)
	}

	def logMessage(kind: String, userId: String, message: String) = {
		val when = System.currentTimeMillis
		(ChatLog.create(kind, roomId, userId, message, when).frozen.timestamp, when)
	}

	def welcomeMessage(connectionId: Int): Enumerator[JsValue] = {
		Enumerator(Json.obj(
			"kind" -> "welcome",
			"connectionId" -> connectionId,
			"users" -> connections.flatMap { connection =>
				User.findById(connection._1).map(_.frozen).map { user =>
					Json.obj(
						"userId" -> user.id,
						//"connectionId" -> connection.connectionId,
						"email" -> user.email,
						"nickname" -> user.firstName)
				}
			}))
	}

	def addConnection(userId: String, producer: Enumerator[JsValue], channel: Concurrent.Channel[JsValue], connectionId: Int) = {
		connections = connections + (userId -> (connections.getOrElse(userId, List()) :+ Connection(producer, channel, connectionId)))
		Logger.info("[Chat] Connection established: " + connections.toString)
	}

	def removeConnection(userId: String, connectionId: Int) = {
		// clear sessions for userid. if none exists for a userid, remove userid key.
		connections.get(userId).foreach { userConns =>
			val newUserConns = userConns.filterNot(_.connectionId == connectionId)
			connectionUsage.free(connectionId)
			if (newUserConns.isEmpty)
				connections = connections - userId
			else
				connections = connections + (userId -> newUserConns)

		}
	}

	def quit(userId: String, producer: Enumerator[JsValue], connectionId: Int) = {

		removeConnection(userId, connectionId)

		val numConnections = connections.foldLeft(0) { (num, connection) =>
			num + connection._2.length
		}

		Logger.info("Number of active connections for chat(" + roomId + "): " + numConnections)
		Logger.info(s"[Chat] user $userId joined to chat room $roomId ")
	}

	def receive = {

		case Join(userId, timestampOpt) => {

			if (false /* maximum connection per user constraint here*/ ) {
				sender ! CannotConnect("You have reached your maximum number of connections.")
			} else {
				val connectionId = connectionUsage.allocate
				// Create an Enumerator to write to this socket
				//val producer = Enumerator.imperative[JsValue](onStart = () => self ! NotifyJoin(userId, connectionId))
				val savedSelf = self
				lazy val producer: Enumerator[JsValue] = Concurrent.unicast[JsValue](onStart = { channel =>
					addConnection(userId, producer, channel, connectionId)
					ChatRoom.addUser(roomId, userId)
					self ! NotifyJoin(userId, connectionId)
				}, onError = { (msg, input) =>
					connectionUsage.free(connectionId)
				})
				// previous messages
				val prev = Enumerator(prevMessages(timestampOpt).map { chatlog => ChatLog.toJson(chatlog) }: _*)
				sender ! Connected(producer, prev >>> welcomeMessage(connectionId), connectionId)
			}
		}

		case GetPrevMessages(startTs, endTs) =>
			val prev = prevMessages(startTs, endTs).map(ChatLog.toJson(_))
			sender ! JsArray(prev)

		case NotifyJoin(userId, connectionId) => {
			val user = User.findById(userId).map(_.frozen).get
			val nickname = user.firstName + " " + user.lastName
			notifyAll("join", userId, connectionId, "has entered")
		}

		case Talk(userId, connectionId: Int, text) => {
			notifyAll("talk", userId, connectionId, text)
		}

		case Quit(userId, producer, connectionId) => {
			quit(userId, producer, connectionId)
			ChatRoom.removeUser(roomId, userId)
			notifyAll("quit", userId, 0, "has left")
			Logger.info(s"[CHAT] user $userId quit from room $roomId")
		}

	}

	def notifyAll(kind: String, userId: String, connectionId: Int, message: String) {

		val user = User.findById(userId).map(_.frozen).get
		val email = user.email
		val nickname = user.firstName.get + " " + user.lastName.get

		val msg: JsValue = kind match {
			case "talk" =>
				Json.obj(
					"kind" -> kind,
					"userId" -> userId,
					"email" -> email,
					"message" -> message,
					"connectionId" -> connectionId)

			case "join" =>
				val connectionCountForUser = connections.count(_._1 == userId)

				Json.obj(
					"kind" -> kind,
					"userId" -> userId,
					"email" -> email,
					"nickname" -> nickname,
					"message" -> Json.obj("nickname" -> nickname, "numConnections" -> connectionCountForUser).toString,
					"connectionId" -> connectionId)
			case "quit" =>
				val connectionCountForUser = connections.count(_._1 == userId)

				Json.obj(
					"kind" -> kind,
					"userId" -> userId,
					"email" -> email,
					"message" -> Json.obj("numConnections" -> connectionCountForUser).toString)
		}

		val (timestamp, when) = logMessage(kind, userId, (msg \ "message").as[String])

		connections.foreach {
			case (_, connectionForUser) =>
				connectionForUser.foreach {
					case Connection(_, channel, _) => channel.push(msg.as[JsObject] ++ Json.obj("timestamp" -> timestamp, "when" -> when))
				}
		}
	}
}
