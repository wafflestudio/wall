package wall

import play.api.libs.iteratee._
import akka.actor._
import play.api.libs.concurrent.Execution.Implicits._
import scala.concurrent.duration._
import scala.concurrent.Future
import scala.concurrent.Promise
import akka.pattern.ask
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.Logger
import play.api.libs.json._
import models.User
import models.WallLog
import models.Sheet
import models.SheetLink
import utils.StringWithState
import utils.Operation
import akka.util.Timeout
import models.ActiveRecord._
import utils.UsageSet
import models.AlterTextRecord

class WallActor(wallId: String) extends Actor {

	implicit def toDouble(value: JsValue) = { value.as[Double] }
	implicit def toLong(value: JsValue) = { value.as[Long] }

	val connectionUsage = new UsageSet
	case class Connection(channel:Concurrent.Channel[JsValue], uuid: String, connectionId: Int, isVolatile: Boolean = false)

	// key: userId, values: list of sessions user have
	var connections = Map.empty[String, List[Connection]]
	// trick to track pending messages for each session (session, timestamp, action)
	var recentRecords = List[AlterTextRecord]()
	// shutdown timer activated when no connection is left to the actor
	var shutdownTimer: Option[akka.actor.Cancellable] = None

	def addConnection(userId: String, uuid: String, channel: Concurrent.Channel[JsValue]) = {
		val connectionId = connectionUsage.allocate
		connections = connections + (userId -> (connections.getOrElse(userId, List()) :+ Connection(channel, uuid, connectionId)))
		connectionId
	}

	def removeConnection(userId: String, connectionId: Int) = {
		connections.get(userId).foreach { userConns =>
			val newUserConns = userConns.filter(_.connectionId != connectionId)
			if (newUserConns.isEmpty)
				connections = connections - userId
			else
				connections = connections + (userId -> newUserConns)
		}
	}

	def numConnections = connections.foldLeft[Int](0) { (num, userConnections) =>
		num + userConnections._2.length
	}

	def connectionsAsString = connections.foldLeft("") { (str, userConnections) =>
		str + userConnections._2.foldLeft("") { (str, conn) =>
			str + { if (str.isEmpty()) { "" } else { "," } } + conn.uuid
		}
	}

	def receive = {
		// Join
		case Join(userId, uuid, timestamp, syncOnce) => {
			// Create an Enumerator to write to this socket
			val wallActor = self
			
			val channelPromise = Promise[Concurrent.Channel[JsValue]]()
			
			val producer: Enumerator[JsValue] = Concurrent.unicast[JsValue] { channel =>
				channelPromise.success(channel)
			}
			
			channelPromise.future.onSuccess {
				case channel =>
    				val prev = Enumerator(prevLogs(timestamp).map(_.toJson): _*)
    
        			if (false /* maximum connection per user constraint here*/ ) {
        				sender ! CannotConnect("Wall has reached maximum number of connections.")
        			}
        			else {
        				// deactivate shutdown timer if activated
        				shutdownTimer.map { cancellable =>
        					cancellable.cancel()
        					shutdownTimer = None
        				}
        				// update connections map
        				val connectionId = addConnection(userId, uuid, channel)
        				sender ! Connected(channel, prev >>> producer, connectionId)
        				if (syncOnce) {
        					Logger.info(s"[Wall] user $userId:($uuid) syncing with wall $wallId")
        				}
        				else {
        					Logger.info(s"[Wall] user $userId:($uuid / $connectionId) joined to wall $wallId")
        					Logger.info("[Wall] Number of active connections for wall(" + wallId + "): " + numConnections)
        
        					Logger.info(s"[Wall] connections: (${connectionsAsString})")
        				}
        			}
			}
			
			
			
		}
		case RetryFinish =>
			//start scheduling shutdown if no connections left
			if (numConnections == 0)
				shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) { context.parent ! Finishing(wallId) })
		// ACK
		case Action(json, _, _, ack: Ack) =>
			Logger.debug("ack came(" + ack.timestamp + ").")
		// reserved for future use..
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
							}
							else { // apply arrived consolidated record
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
		val msg = log.toJson
		// notify all producers
		connections.foreach {
			case (_, userConns) =>
				userConns.foreach { connection =>
					val channel = connection.channel
					channel.push(msg)
				}
		}
		log.id
	}

	def prevLogs(timestamp: Long) =
		WallLog.list(wallId, timestamp).map(_.frozen)

	def logMessage(kind: String, basetimestamp: Long, userId: String, message: String) =
		WallLog.create(kind, wallId, basetimestamp, userId, message).frozen

	def quit(userId: String, uuid: String, connectionId: Int) = {
		// clear sessions for userid. if none exists for a userid, remove userid key.
		removeConnection(userId, connectionId)

		//start scheduling shutdown
		if (numConnections == 0)
			shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) { context.parent ! Finishing(wallId) })

		Logger.info(s"[Wall] user $userId quit from wall $wallId")
		Logger.info("Number of active connections for wall(" + wallId + "): " + numConnections)
	}

}
