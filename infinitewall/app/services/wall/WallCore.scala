package services.wall

import scala.concurrent.duration.DurationInt
import akka.actor.{ Actor, actorRef2Scala }
import akka.pattern.ask
import models.{ AlterTextRecord, Sheet, SheetLink, WallLog }
import play.api.Logger
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.iteratee.{ Concurrent, Enumerator }
import play.api.libs.json.{ JsObject, JsValue, Json }
import play.api.libs.json._
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import utils.StringWithState
import play.api.libs.json._
import services.ConnectionManager
import akka.actor.ActorRef

class WallCoreActor(wallId: String, wallActor: ActorRef) extends Actor {

	implicit def toDouble(value: JsValue) = { value.as[Double] }
	implicit def toLong(value: JsValue) = { value.as[Long] }

	def prevLogs(timestamp: Long) =
		WallLog.findByWall(wallId, timestamp).map(_.frozen)

	def logMessage(kind: String, basetimestamp: Long, userId: String, message: String) =
		WallLog.create(kind, wallId, basetimestamp, userId, message).frozen

	def update(action: Action): Option[WallLog.Frozen] = {
		action match {
			// ACK
			case Action(json, _, _, ack: Ack) =>
				Logger.debug("ack came(" + ack.timestamp + ").")
				None

			// Create Action
			case Action(json, uuid, connectionIdOpt, c: CreateAction) =>
				val sheetId = Sheet.create(c.x, c.y, c.width, c.height, c.title, c.contentType, c.content, wallId).frozen.id
				val addSheetId = (__ \ "params").json.update(__.read[JsObject].map(_ ++ Json.obj("sheetId" -> sheetId)))
				Some(logMessage("action", c.timestamp, c.userId, json.validate(addSheetId).get.toString))
			// Other Action
			case Action(json, uuid, connectionIdOpt, action: ActionDetailWithId) =>
				Sheet.find(action.sheetId).map(_.frozen).map { sheet =>

					action match {
						case a: MoveAction =>
							Sheet.move(a.sheetId, a.x, a.y)
							logMessage("action", action.timestamp, action.userId, json.toString)
						case a: ResizeAction =>
							Sheet.resize(a.sheetId, a.width, a.height)
							logMessage("action", action.timestamp, action.userId, json.toString)
						case a: RemoveAction =>
							Sheet.remove(a.sheetId) //former delete
							logMessage("action", action.timestamp, action.userId, json.toString)
						case a: SetTitleAction =>
							Sheet.setTitle(a.sheetId, a.title)
							logMessage("action", action.timestamp, action.userId, json.toString)
						case a: SetTextAction =>
							Sheet.setText(a.sheetId, a.text)
							logMessage("action", action.timestamp, action.userId, json.toString)
						case action: AlterTextAction =>
							// simulate consolidation of records after timestamp
							val records: List[AlterTextRecord] = WallLog.findAllAlterTextRecordForSheet(wallId, action.sheetId, action.timestamp)

							var pending = action.operations // all mine with > a.timestamp

							for (record <- records) {
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
							logMessage("action", action.timestamp, action.userId, newAction.json.toString)
						case a: SetLinkAction =>
							SheetLink.create(a.sheetId, a.toSheetId, wallId)
							logMessage("action", action.timestamp, action.userId, json.toString)
						case a: RemoveLinkAction =>
							SheetLink.remove(a.sheetId, a.toSheetId)
							SheetLink.remove(a.toSheetId, a.sheetId)
							logMessage("action", action.timestamp, action.userId, json.toString)
					}
				}
		}
	}

	//	def quit(userId: String, uuid: String, connectionId: Int) = {
	//		// clear sessions for userid. if none exists for a userid, remove userid key.
	//		connectionManager.removeConnection(userId, connectionId)
	//
	//		//start scheduling shutdown
	//		if (!connectionManager.hasConnection)
	//			beginShutdownCountdown
	//
	//		Logger.info(s"[Wall] user $userId quit from wall $wallId")
	//		Logger.info("Number of active connections for wall(" + wallId + "): " + connectionManager.numConnections)
	//	}

	def receive = {
		//		// Join
		//		case Join(userId, uuid, timestamp, syncOnce) => {
		//			// Create an Enumerator to write to this socket
		//			val wallActor = self
		//
		//			if (false /* maximum connection per user constraint here*/ ) {
		//				sender ! CannotConnect("Wall has reached maximum number of connections.")
		//			} else {
		//				stopShutdownCountdown
		//
		//				val connectionId = connectionManager.allocate
		//
		//				lazy val producer: Enumerator[JsValue] = Concurrent.unicast[JsValue](onStart = { channel =>
		//					// update connections map
		//					connectionManager.addConnection(userId, uuid, producer, channel, connectionId)
		//				}, onError = { (msg, input) =>
		//					connectionManager.free(connectionId)
		//				})
		//
		//				val prev = Enumerator(prevLogs(timestamp).map(_.toJson): _*)
		//
		//				sender ! Connected(producer, prev, connectionId)
		//
		//				if (syncOnce) {
		//					Logger.info(s"[Wall] user $userId:($uuid) syncing with wall $wallId")
		//				} else {
		//					Logger.info(s"[Wall] user $userId:($uuid / $connectionId) joined to wall $wallId")
		//					Logger.info("[Wall] Number of active connections for wall(" + wallId + "): " + connectionManager.numConnections)
		//
		//					Logger.info(s"[Wall] connections: (${connectionManager.connectionsAsString})")
		//				}
		//			}
		//		}
		/*case CheckInactive =>
			//start scheduling shutdown if no connections left
			if (!connectionManager.hasConnection)
				beginShutdownCountdown
				* 
				*/
		case action: Action =>
			// update action and broadcast if needed
			val logOption = update(action)
			logOption.map { wallLog =>
				wallActor ! Broadcast(wallLog.toJson)
			}
		//		// Quit
		//		case Quit(userId, uuid, connectionId, wasPersistent) => {
		//			quit(userId, uuid, connectionId)
		//			if (wasPersistent)
		//				broadcast(logMessage("userQuit", 0, userId, ""))
		//		}
	}

}
