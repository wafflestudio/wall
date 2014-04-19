package wall

import scala.concurrent.duration.DurationInt

import akka.actor.{ Actor, actorRef2Scala }
import models.{ AlterTextRecord, Sheet, SheetLink, WallLog }
import models.ActiveRecord.transactional
import play.api.Logger
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.iteratee.{ Concurrent, Enumerator }
import play.api.libs.json.{ JsObject, JsValue, Json }
import play.api.libs.json._
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import utils.{ StringWithState, UsageSet }

class ConnectionManager {
	val connectionUsage = new UsageSet
	case class Connection(enumerator: Enumerator[JsValue], channel: Concurrent.Channel[JsValue], uuid: String, connectionId: Int, isVolatile: Boolean = false)

	// key: userId, values: list of sessions user have
	private var connectionsPerUser = Map.empty[String, List[Connection]]

	def allocate = connectionUsage.allocate

	def free(connectionId: Int) = connectionUsage.free(connectionId)

	def addConnection(userId: String, uuid: String, enumerator: Enumerator[JsValue], channel: Concurrent.Channel[JsValue], connectionId: Int) = {
		connectionsPerUser = connectionsPerUser + (userId -> (connectionsPerUser.getOrElse(userId, List()) :+ Connection(enumerator, channel, uuid, connectionId)))
	}

	def removeConnection(userId: String, connectionId: Int) = {
		connectionUsage.free(connectionId)
		connectionsPerUser.get(userId).foreach { userConns =>
			val newUserConns = userConns.filter(_.connectionId != connectionId)
			if (newUserConns.isEmpty)
				connectionsPerUser = connectionsPerUser - userId
			else
				connectionsPerUser = connectionsPerUser + (userId -> newUserConns)
		}
	}

	def numConnections = connectionsPerUser.foldLeft[Int](0) { (num, userConnections) =>
		num + userConnections._2.length
	}

	def hasConnection = !connectionsPerUser.isEmpty && numConnections != 0

	def connectionsAsString = connectionsPerUser.foldLeft("") { (str, userConnections) =>
		str + userConnections._2.foldLeft("") { (str, conn) =>
			str + { if (str.isEmpty()) { "" } else { "," } } + conn.uuid
		}
	}

	def connections = connectionsPerUser.flatMap {
		case (_, userConns) =>
			userConns
	}

}

class WallActor(wallId: String) extends Actor {

	implicit def toDouble(value: JsValue) = { value.as[Double] }
	implicit def toLong(value: JsValue) = { value.as[Long] }

	// trick to track pending messages for each session (session, timestamp, action)
	var recentRecords = List[AlterTextRecord]()

	val connectionManager = new ConnectionManager

	// shutdown timer activated when no connection is left to the actor
	var shutdownTimer: Option[akka.actor.Cancellable] = None

	def beginCountdown = {
		shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) { context.parent ! Inactive(wallId) })
	}

	def stopCountdown = {
		// deactivate shutdown timer if activated
		shutdownTimer.foreach { cancellable =>
			cancellable.cancel()
			shutdownTimer = None
		}
	}

	def receive = {
		// Join
		case Join(userId, uuid, timestamp, syncOnce) => {
			// Create an Enumerator to write to this socket
			val wallActor = self

			if (false /* maximum connection per user constraint here*/ ) {
				sender ! CannotConnect("Wall has reached maximum number of connections.")
			} else {
				stopCountdown

				val connectionId = connectionManager.allocate

				lazy val producer: Enumerator[JsValue] = Concurrent.unicast[JsValue](onStart = { channel =>
					// update connections map
					connectionManager.addConnection(userId, uuid, producer, channel, connectionId)
				}, onError = { (msg, input) =>
					connectionManager.free(connectionId)
				})

				val prev = Enumerator(prevLogs(timestamp).map(_.toJson): _*)

				sender ! Connected(producer, prev, connectionId)

				if (syncOnce) {
					Logger.info(s"[Wall] user $userId:($uuid) syncing with wall $wallId")
				} else {
					Logger.info(s"[Wall] user $userId:($uuid / $connectionId) joined to wall $wallId")
					Logger.info("[Wall] Number of active connections for wall(" + wallId + "): " + connectionManager.numConnections)

					Logger.info(s"[Wall] connections: (${connectionManager.connectionsAsString})")
				}
			}
		}
		case CheckInactive =>
			//start scheduling shutdown if no connections left
			if (!connectionManager.hasConnection)
				beginCountdown
		// ACK
		case Action(json, _, _, ack: Ack) =>
			Logger.debug("ack came(" + ack.timestamp + ").")
		// reserved for future use..
		case Talk(text, uuid, connectionId) =>
		// TODO

		// Create Action
		case Action(json, uuid, connectionId, c: CreateAction) =>
			val sheetId = Sheet.create(c.x, c.y, c.width, c.height, c.title, c.contentType, c.content, wallId).frozen.id
			val addSheetId = (__ \ "params").json.update(__.read[JsObject].map(_ ++ Json.obj("sheetId" -> sheetId)))
			notifyAll("action", c.timestamp, c.userId, uuid, json.validate(addSheetId).get.toString)
		// Other Action
		case Action(json, uuid, connectionId, action: ActionDetailWithId) =>
			Sheet.findById(action.sheetId).map(_.frozen).map { sheet =>

				action match {
					case a: MoveAction => Sheet.move(a.sheetId, a.x, a.y)
					case a: ResizeAction => Sheet.resize(a.sheetId, a.width, a.height)
					case a: RemoveAction => Sheet.remove(a.sheetId) //former delete
					case a: SetTitleAction => Sheet.setTitle(a.sheetId, a.title)
					case a: SetTextAction => Sheet.setText(a.sheetId, a.text)
					case action: AlterTextAction =>
						// simulate consolidation of records after timestamp
						val records: List[AlterTextRecord] = transactional {
							WallLog.listAlterTextRecord(wallId, action.sheetId, action.timestamp)
						}
						var pending = action.operations // all mine with > a.timestamp

						records.foreach { record =>
							if (record.uuid == action.uuid) {
								// drop already consolidated. 
								if (pending.head.msgId != record.msgId)
									Logger.warn(s"pending: ${pending.head.msgId} != record: ${record.msgId}")
								pending = pending.drop(1)
							} else { // apply arrived consolidated record
								val ss = new StringWithState(record.baseText)
								ss.apply(record.operation, 1)
								// transform pending
								pending = pending.map { p =>
									OperationWithState(ss.apply(p.op, 0), p.msgId)
								}
								Logger.debug("simulation: " + ss.text)
							}
						}

						val newOperation = pending.head.op
						val (baseText, undoOp) = Sheet.alterText(action.sheetId, newOperation)
						val newAction = AlterTextAction(action.userId, action.uuid, action.sheetId, action.timestamp,
							List(OperationWithState(newOperation, action.operations.last.msgId)), undoOp)
						val newTimestamp = notifyAll("action", action.timestamp, action.userId, uuid, newAction.json.toString)

					case a: SetLinkAction => SheetLink.create(a.sheetId, a.toSheetId, wallId)
					case a: RemoveLinkAction =>
						SheetLink.remove(a.sheetId, a.toSheetId)
						SheetLink.remove(a.toSheetId, a.sheetId)
				}

				action match {
					case a: AlterTextAction =>
					case _ =>
						notifyAll("action", action.timestamp, action.userId, uuid, json.toString)
				}
			}

		// Quit
		case Quit(userId, uuid, connectionId, wasPersistent) => {
			quit(userId, uuid, connectionId)
			if (wasPersistent)
				notifyAll("userQuit", 0, userId, uuid, "")
		}
	}

	def notifyAll(kind: String, basetimestamp: Long, userId: String, uuid: String, detail: String) = {
		val log = logMessage(kind, basetimestamp, userId, detail)
		// notify all producers
		connectionManager.connections.foreach(_.channel.push(log.toJson))
		log.id
	}

	def prevLogs(timestamp: Long) =
		WallLog.list(wallId, timestamp).map(_.frozen)

	def logMessage(kind: String, basetimestamp: Long, userId: String, message: String) =
		WallLog.create(kind, wallId, basetimestamp, userId, message).frozen

	def quit(userId: String, uuid: String, connectionId: Int) = {
		// clear sessions for userid. if none exists for a userid, remove userid key.
		connectionManager.removeConnection(userId, connectionId)

		//start scheduling shutdown
		if (!connectionManager.hasConnection)
			beginCountdown

		Logger.info(s"[Wall] user $userId quit from wall $wallId")
		Logger.info("Number of active connections for wall(" + wallId + "): " + connectionManager.numConnections)
	}

}
