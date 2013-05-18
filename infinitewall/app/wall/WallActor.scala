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


// Record used for tracking text change (cache)
case class Record(timestamp: Long, sheetId: String, baseText: String, resultText: String, consolidated: Operation, conn: Enumerator[JsValue])


class WallActor(wallId: String) extends Actor {

  implicit def toDouble(value: JsValue) = { value.as[Double] }
  implicit def toLong(value: JsValue) = { value.as[Long] }

  val connectionUsage = new UsageSet
  case class Connection(enumerator: PushEnumerator[JsValue], timestamp: Long, connectionId:Int)

  // key: userId, values: list of sessions user have
  var connections = Map.empty[String, List[Connection]]
  // trick to track pending messages for each session (session, timestamp, action)
  var recentRecords = List[Record]()
  // shutdown timer activated when no connection is left to the actor
  var shutdownTimer: Option[akka.actor.Cancellable] = None
  
  // TODO: complete this
  def loadRecords(minTs:Long) = {
    
  }

  def prevLogs(timestamp: Long) = WallLog.list(wallId, timestamp).map(_.frozen)
  def logMessage(kind: String, basetimestamp: Long, userId: String, message: String) = WallLog.create(kind, wallId, basetimestamp, userId, message).frozen.timestamp

  def quit(userId: String, producer: Enumerator[JsValue]) = {
    // clear sessions for userid. if none exists for a userid, remove userid key.
    connections.get(userId).foreach { userConns =>
      val newUserConns = userConns.filterNot(_.enumerator == producer)

      if (newUserConns.isEmpty)
        connections = connections - userId
      else
        connections = connections + (userId -> newUserConns)

    }
    cleanRecentRecords()

    val numConnections = connections.foldLeft(0) { (num, connection) =>
      num + connection._2.length
    }

    //start scheduling shutdown
    if (numConnections == 0)
      shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) { context.parent ! Finishing(wallId) })

    Logger.info("Number of active connections for wall(" + wallId + "): " + numConnections)
  }

  def updateTimestamp(userId: String, ts: Long, origin: Enumerator[JsValue]) = {

    connections.get(userId).foreach { userConns =>
      val newUserConns = userConns.map { connection =>
        if (connection.enumerator == origin)
          Connection(connection.enumerator, ts, connection.connectionId)
        else
          connection
      }
      connections = connections + (userId -> newUserConns)
    }
  }

  def cleanRecentRecords() = {
    var minTs: Long = 0
    connections.foreach { case (_,userConns) =>
      userConns.foreach { conn =>
        if (minTs == 0 || conn.timestamp < minTs)
          minTs = conn.timestamp
      }
    }

    recentRecords = recentRecords.dropWhile(_.timestamp < minTs)
  }

  def receive = {
    // Join
    case Join(userId, timestamp) => {
      // Create an Enumerator to write to this socket
      val wallActor = self
      val connectionId = connectionUsage.allocate
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
        connections = connections + (userId -> (connections.getOrElse(userId, List()) :+ Connection(producer, timestamp, connectionId)))
        sender ! Connected(producer, prev)

        Logger.info(s"[Wall] user $userId joined to wall $wallId ")
      }
    }
    case RetryFinish =>
      val numConnections = connections.foldLeft[Int](0) { (num, connection) =>
        num + connection._2.length
      }

      //start scheduling shutdown if no connections left
      if (numConnections == 0)
        shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) { context.parent ! Finishing(wallId) })

    // ACK
    case Action(json, ack: Ack, origin) =>
      Logger.debug("ack came(" + ack.timestamp + ").")
      updateTimestamp(ack.userId, ack.timestamp, origin)
      cleanRecentRecords()
    // Create Action
    case Action(json, c: CreateAction, origin) =>
      val sheetId = Sheet.create(c.x, c.y, c.width, c.height, c.title, c.contentType, c.content, wallId).frozen.id
      notifyAll("action", c.timestamp, c.userId, (json.as[JsObject] ++ Json.obj("id" -> sheetId)).toString, origin)
    // Other Action
    case Action(json, action: ActionDetailWithId, origin) =>
      Sheet.findById(action.id).map(_.frozen).map { sheet =>

        action match {
          case a: MoveAction => Sheet.move(a.id, a.x, a.y)
          case a: ResizeAction => Sheet.resize(a.id, a.width, a.height)
          case a: RemoveAction => Sheet.remove(a.id) //former delete
          case a: SetTitleAction => Sheet.setTitle(a.id, a.title)
          case a: SetTextAction => Sheet.setText(a.id, a.text)
          case action: AlterTextAction =>
            // simulate consolidation of records after timestamp
            val records = recentRecords.dropWhile(_.timestamp <= action.timestamp).filter(_.sheetId == action.id)
            var pending = action.operations // all mine with > a.timestamp

            assert(pending.size - 1 == records.filter(_.conn == origin).size,
              "pending:" + (pending.size - 1) + " record:" + records.filter(_.conn == origin).size)

            records.foreach { record =>
              if (record.conn == origin) {
                // drop already consolidated. 
                pending = pending.drop(1)
              }
              else { // apply arrived consolidated record
                val ss = new StringWithState(record.baseText)
                ss.apply(record.consolidated, 1)
                // transform pending
                pending = pending.map { p =>
                  OperationWithState(ss.apply(p.op, 0), p.msgId)
                }
                Logger.debug("simulation: " + ss.text)
              }
            }

            val newOp = pending.head.op
            val (baseText, resultText) = Sheet.alterText(action.id, newOp.from, newOp.length, newOp.content)
            val newAction = AlterTextAction(action.userId, action.timestamp, action.id, List(OperationWithState(newOp, action.operations.last.msgId)))
            val newTimestamp = notifyAll("action", action.timestamp, action.userId, newAction.singleJson.toString, origin)

            recentRecords = recentRecords :+ Record(newTimestamp, action.id, baseText, resultText, newOp, origin)

          case a: SetLinkAction => SheetLink.create(a.id, a.to_id, wallId)
          case a: RemoveLinkAction =>
            SheetLink.remove(a.id, a.to_id)
            SheetLink.remove(a.to_id, a.id)
        }

        action match {
          case a: AlterTextAction =>
          case _ =>
            notifyAll("action", action.timestamp, action.userId, json.toString, origin)
        }
      }

    // Quit
    case Quit(userId, producer) => {
      quit(userId, producer)
      notifyAll("userQuit", 0, userId, "", producer)
      Logger.info(s"[Wall] user $userId quit from wall $wallId")
    }

  }

  def notifyAll(kind: String, basetimestamp: Long, userId: String, detail: String, origin: Enumerator[JsValue]) = {

    val username = User.findById(userId).map(_.frozen).get.email
    val logId = logMessage(kind, basetimestamp, userId, detail)
    val msg = Json.obj(
      "kind" -> kind,
      "username" -> username,
      "detail" -> detail,
      "timestamp" -> logId
    )

    // notify all producers
    connections.foreach {
      case (_, userConns) =>
        userConns.foreach { connection =>
          val producer = connection.enumerator
          if (producer == origin)
            producer.push(msg ++ Json.obj("mine" -> true, "timestamp" -> logId))
          else
            producer.push(msg ++ Json.obj("timestamp" -> logId))
        }
    }

    logId
  }

}