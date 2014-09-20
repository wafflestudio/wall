package services.chat

import scala.concurrent.duration._
import scala.concurrent.Future
import akka.actor._
import models.ChatLog
import models.ChatRoom
import models.User
import play.api.Logger
import play.api.libs.concurrent._
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.iteratee._
import play.api.libs.iteratee.Concurrent.Channel
import play.api.libs.json._
import utils.UsageSet
import play.libs.Akka
import services.TerminateConnection
import services.ServiceMessage
import services.Connection

case class Join(userId: String, connectionId: Int, timestampOpt: Option[Long])
case class NotifyQuit(userId: String, connectionId: Int)

case class Talk(userId: String, connectionId: Int, text: String)

case class ListConnections()
case class NumConnections()

case class Broadcast(msg: JsValue, timestamp: Long, when: Long)
case class Respond(userId: String, connectionId: Int, msg: JsValue)

case class NotifyJoin(userId: String, connectionId: Int)
case class GetPrevMessages(startTs: Long, endTs: Long)

case class Connected(enumerator: Enumerator[JsValue], prev: Enumerator[JsValue], connectionId: Int)
case class CannotConnect(msg: String)

case class Message(kind: String, email: String, text: String)

class ChatRoomActor(roomId: String) extends Actor {

	/* connection management */

	private var connections = Map.empty[String, List[Connection]]
	private var connectionIdPool = new UsageSet

	private def numConnections = connections.foldLeft(0) { (sum, el) =>
		sum + el._2.length
	}

	def addConnection(userId: String, channel: Future[Concurrent.Channel[JsValue]]) = {
		val connectionId = connectionIdPool.allocate
		connections = connections + (userId -> (connections.getOrElse(userId, List()) :+ Connection(channel, connectionId)))
		//Logger.info("[Chat] Connection established: " + connections.toString)
		Logger.info(s"[Chat] user $userId joined to chat room $roomId ")
		Logger.info("Number of active connections for chat(" + roomId + "): " + numConnections)

		connectionId
	}

	def removeConnection(userId: String, channel: Future[Channel[JsValue]]) = {
		// clear sessions for userid. if none exists for a userid, remove userid key.
		val connectionId = connections.get(userId).flatMap { userConns =>

			val connectionId = userConns.find(_.channel == channel).map { conn =>
				connectionIdPool.free(conn.connectionId)
				conn.connectionId
			}

			val newUserConns = userConns.filterNot(_.channel == channel)

			if (newUserConns.isEmpty)
				connections = connections - userId
			else
				connections = connections + (userId -> newUserConns)

			connectionId
		}

		Logger.info(s"[Chat] user $userId quit from chat room $roomId ")
		Logger.info("Number of active connections for chat(" + roomId + "): " + numConnections)

		connectionId
	}

	lazy val core = Akka.system.actorOf(Props(new ChatCoreActor(roomId, self)))

	def receive = {
		case ServiceMessage(userId, channel, content) =>
			val connectionIdOpt = (content \\ "connectionId").headOption.map(_.as[Int])
			val timestampOpt = (content \\ "timestamp").headOption.map(_.as[Long])

			(content \ "type").as[String] match {
				case "join" =>
					/* join */
					val connectionId = addConnection(userId, channel)
					core ! Join(userId, connectionId, timestampOpt)
					core ! NotifyJoin(userId, connectionId)
				case "talk" =>
					val text = (content \ "text").as[String]
					core ! Talk(userId, connectionIdOpt.get, text)
				case "quit" =>
					val maybeConnectionId = removeConnection(userId, channel)
					for (connectionId <- maybeConnectionId)
						core ! NotifyQuit(userId, connectionId)

				case "_" =>

			}
		case TerminateConnection(userId, channel) =>
			val maybeConnectionId = removeConnection(userId, channel)
			for (connectionId <- maybeConnectionId)
				core ! NotifyQuit(userId, connectionId)

		case ListConnections =>
			sender ! connections
		case NumConnections =>
			sender ! numConnections

		case Broadcast(msg, timestamp, when) =>
			val path = s"chat/$roomId"
			val msgWithPath = msg.as[JsObject] + ("path" -> Json.toJson(path))

			connections.foreach {
				case (_, connectionForUser) =>
					connectionForUser.foreach {
						case Connection(channel, _) => channel.map(_.push(msgWithPath.as[JsObject] ++ Json.obj("timestamp" -> timestamp, "when" -> when)))
					}
			}
		case Respond(userId, connectionId, msg) =>
			val path = s"chat/$roomId"
			val msgWithPath = msg.as[JsObject] + ("path" -> Json.toJson(path))

			connections.get(userId).get.find(_.connectionId == connectionId).map { connection =>
				connection.channel.map(_.push(msgWithPath))
			}
		case _ =>
			Logger.info("undefined message type")
	}
}

