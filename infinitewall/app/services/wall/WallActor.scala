package services.wall

import models.{ AlterTextRecord, Sheet, SheetLink, WallLog }
import scala.concurrent.duration._
import scala.concurrent.Future
import akka.actor._
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

case class Broadcast(msg: JsValue)
case class Respond(userId: String, connectionId: Int, msg: JsValue)
// Messages
// WallSystem -> WallSystem Actor
case class JoinWall(wallId: String, userId: String, uuid: String, timestamp: Long, syncOnce: Boolean = false)
case class QuitWall(wallId: String, userId: String, uuid: String, connectionId: Int, wasPersistent: Boolean = false)
case class ActionInWall(wallId: String, userId: String, uuid: String, connectionId: Int, actionJson: JsValue)
case class Inactive(wallId: String)
case class CheckInactive()

// WallSystem Actor -> Wall Actor
case class Join(userId: String, uuid: String, timestamp: Long, syncOnce: Boolean = false)
case class Quit(userId: String, uuid: String, connectionId: Int, wasPersistent: Boolean = false)
case class Action(json: JsValue, uuid: String, connectionIdOpt: Option[Int], parsed: ActionDetail)
case class Talk(text: String, uuid: String, connectionId: Int)

// Wall Actor reply
case class Connected(enumerator: Enumerator[JsValue], prevMessages: Enumerator[JsValue], connectionId: Int)
case class CannotConnect(msg: String)

class WallActor(wallId: String) extends Actor {

	implicit def toDouble(value: JsValue) = { value.as[Double] }
	implicit def toLong(value: JsValue) = { value.as[Long] }

	private var connections = Map.empty[String, List[Connection]]
	private var connectionIdPool = new UsageSet

	private def numConnections = connections.foldLeft(0) { (sum, el) =>
		sum + el._2.length
	}

	def addConnection(userId: String, channel: Future[Concurrent.Channel[JsValue]]) = {
		val connectionId = connectionIdPool.allocate
		connections = connections + (userId -> (connections.getOrElse(userId, List()) :+ Connection(channel, connectionId)))
		Logger.info("[Chat] Connection established: " + connections.toString)
		connectionId
	}

	def removeConnection(userId: String, channel: Future[Channel[JsValue]]) = {
		// clear sessions for userid. if none exists for a userid, remove userid key.
		connections.get(userId).foreach { userConns =>

			userConns.find(_.channel == channel).map { conn =>
				connectionIdPool.free(conn.connectionId)
			}

			val newUserConns = userConns.filterNot(_.channel == channel)

			if (newUserConns.isEmpty)
				connections = connections - userId
			else
				connections = connections + (userId -> newUserConns)

		}
	}
	// shutdown timer activated when no connection is left to the actor
	var shutdownTimer: Option[akka.actor.Cancellable] = None

	def beginShutdownCountdown = {
		shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallService.shutdownFinalizeTimeout milliseconds) { context.parent ! Inactive(wallId) })
	}

	def stopShutdownCountdown = {
		// deactivate shutdown timer if activated
		shutdownTimer.foreach { cancellable =>
			cancellable.cancel()
			shutdownTimer = None
		}
	}
	lazy val core = Akka.system.actorOf(Props(new WallCoreActor(wallId, self)))

	def receive = {
		case ServiceMessage(userId, channel, content) =>
			val connectionIdOpt = (content \\ "connectionId").headOption.map(_.as[Int])
			val timestampOpt = (content \\ "timestamp").headOption.map(_.as[Long])
			val uuid = (content \ "uuid").as[String]

			(content \ "type").as[String] match {
				case "join" =>
					val connectionId = addConnection(userId, channel)
					core ! Join(userId, uuid, timestampOpt.get)
				case "quit" =>
					removeConnection(userId, channel)
				case "action" =>
					core ! Action(content, uuid, connectionIdOpt, ActionDetail(userId, content))
			}
		case TerminateConnection(userId, channel) =>
			removeConnection(userId, channel)
			Logger.info("Number of active connections for wall(" + wallId + "): " + numConnections)
			Logger.info(s"[Wall] user $userId joined to wall room wallId ")

		case Broadcast(msg) =>
			val path = s"wall/$wallId"
			val msgWithPath = msg.as[JsObject] + ("path" -> Json.toJson(path))

			Logger.info("broadcasting for wall(" + wallId + "): " + numConnections)

			connections.foreach {
				case (_, connectionForUser) =>
					connectionForUser.foreach {
						case Connection(channel, _) => channel.map(_.push(msgWithPath))
					}
			}
		case Respond(userId, connectionId, msg) =>
			connections.get(userId).get.find(_.connectionId == connectionId).map { connection =>
				val path = s"wall/$wallId"
				val msgWithPath = msg.as[JsObject] + ("path" -> Json.toJson(path))
				connection.channel.map(_.push(msgWithPath))
			}
		case _ =>
			Logger.info("undefined message type")
	}

}
