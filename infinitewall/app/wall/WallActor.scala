package wall

import play.api.libs.iteratee._
import akka.actor._
import play.api.libs.concurrent.Execution.Implicits._
import scala.concurrent.duration._
import scala.concurrent.Future
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
  case class Connection(enumerator: PushEnumerator[JsValue], connectionId:Int)

  // key: userId, values: list of sessions user have
  var connections = Map.empty[String, List[Connection]]
  // trick to track pending messages for each session (session, timestamp, action)
  var recentRecords = List[AlterTextRecord]()
  // shutdown timer activated when no connection is left to the actor
  var shutdownTimer: Option[akka.actor.Cancellable] = None
  
  def addConnection(userId: String, enumerator:PushEnumerator[JsValue]) = {
    val connectionId = connectionUsage.allocate
    connections = connections + (userId -> (connections.getOrElse(userId, List()) :+ Connection(enumerator, connectionId)))
    connectionId
  }
  
  def removeConnection(userId: String, connectionId: Int) = {
    connections.get(userId).foreach { userConns =>
      val newUserConns = userConns.filterNot(_.connectionId == connectionId)
      if (newUserConns.isEmpty)
        connections = connections - userId
      else
        connections = connections + (userId -> newUserConns)
    }
  }
  
  def numConnections = connections.foldLeft[Int](0) { (num, connection) =>
    num + connection._2.length
  }

  def receive = {
    // Join
    case Join(userId, timestamp) => {
      // Create an Enumerator to write to this socket
      val wallActor = self
      lazy val producer: PushEnumerator[JsValue] = Enumerator.imperative[JsValue]()
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
        val connectionId = addConnection(userId, producer)
        sender ! Connected(producer, prev, connectionId)
        Logger.info(s"[Wall] user $userId joined to wall $wallId ")
      }
    }
    case RetryFinish =>
      //start scheduling shutdown if no connections left
      if (numConnections == 0)
        shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) { context.parent ! Finishing(wallId) })
    // ACK
    case Action(json, ack: Ack) =>
      Logger.debug("ack came(" + ack.timestamp + ").")
      // reserved for future use..
    // Create Action
    case Action(json, c: CreateAction) =>
      val sheetId = Sheet.create(c.x, c.y, c.width, c.height, c.title, c.contentType, c.content, wallId).frozen.id
      val addSheetId = (__ \ "params").json.update(__.read[JsObject].map(_ ++ Json.obj("sheetId" -> sheetId)))
      notifyAll("action", c.timestamp, c.userId, json.validate(addSheetId).get.toString, c.connectionId)
    // Other Action
    case Action(json, action: ActionDetailWithId) =>
      Sheet.findById(action.sheetId).map(_.frozen).map { sheet =>

        action match {
          case a: MoveAction => Sheet.move(a.sheetId, a.x, a.y)
          case a: ResizeAction => Sheet.resize(a.sheetId, a.width, a.height)
          case a: RemoveAction => Sheet.remove(a.sheetId) //former delete
          case a: SetTitleAction => Sheet.setTitle(a.sheetId, a.title)
          case a: SetTextAction => Sheet.setText(a.sheetId, a.text)
          case action: AlterTextAction =>
            // simulate consolidation of records after timestamp
            val records:List[AlterTextRecord] = transactional {
              WallLog.listAlterTextRecord(wallId, action.sheetId, action.timestamp)
            }
            var pending = action.operations // all mine with > a.timestamp

            assert(pending.size - 1 == records.filter(_.connectionId == action.connectionId).size,
              "pending:" + (pending.size - 1) + " record:" + records.filter(_.connectionId == action.connectionId).size)

            records.foreach { record =>
              if (record.connectionId == action.connectionId) {
                // drop already consolidated. 
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
            val newAction = AlterTextAction(action.userId, action.connectionId, action.sheetId, action.timestamp, 
                List(OperationWithState(newOperation, action.operations.last.msgId)), undoOp)
            val newTimestamp = notifyAll("action", action.timestamp, action.userId, newAction.json.toString, action.connectionId)
           
          case a: SetLinkAction => SheetLink.create(a.sheetId, a.toSheetId, wallId)
          case a: RemoveLinkAction =>
            SheetLink.remove(a.sheetId, a.toSheetId)
            SheetLink.remove(a.toSheetId, a.sheetId)
        }

        action match {
          case a: AlterTextAction =>
          case _ =>
            notifyAll("action", action.timestamp, action.userId, json.toString, action.connectionId)
        }
      }

    // Quit
    case Quit(userId, connectionId) => {
      quit(userId, connectionId)
      notifyAll("userQuit", 0, userId, "", connectionId)
      Logger.info(s"[Wall] user $userId quit from wall $wallId")
    }

  }

  def notifyAll(kind: String, basetimestamp: Long, userId: String, detail: String, connectionId:Int) = {

    val log = logMessage(kind, basetimestamp, userId, detail)
    val msg = log.toJson
    // notify all producers
    connections.foreach {
      case (_, userConns) =>
        userConns.foreach { connection =>
          val producer = connection.enumerator
          if (connection.connectionId == connectionId)
            producer.push(msg.as[JsObject] ++ Json.obj("mine" -> true))
          else
            producer.push(msg)
        }
    }
    log.id
  }
  
  def prevLogs(timestamp: Long) = 
    WallLog.list(wallId, timestamp).map(_.frozen)
  
  def logMessage(kind: String, basetimestamp: Long, userId: String, message: String) =
    WallLog.create(kind, wallId, basetimestamp, userId, message).frozen

  def quit(userId: String, connectionId:Int) = {
    // clear sessions for userid. if none exists for a userid, remove userid key.
    removeConnection(userId, connectionId)
    
    //start scheduling shutdown
    if (numConnections == 0)
      shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) { context.parent ! Finishing(wallId) })

    Logger.info("Number of active connections for wall(" + wallId + "): " + numConnections)
  }


}