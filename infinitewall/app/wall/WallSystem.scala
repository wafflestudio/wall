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

// Messages
// WallSystem -> WallSystem Actor
case class JoinWall(wallId: Long, userId: Long, timestamp: Long)
case class QuitWall(wallId: Long, userId: Long, producer: Enumerator[JsValue])
case class ActionInWall(wallId: Long, json: JsValue, detail: ActionDetail, producer: Enumerator[JsValue] = WallSystem.volatileEnumerator)
case class Finishing(wallId: Long)
case class FinishAccepted()
case class RetryFinish()

// WallSystem Actor -> Wall Actor
case class Join(userId: Long, timestamp: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Action(json: JsValue, detail: ActionDetail, producer: Enumerator[JsValue] = WallSystem.volatileEnumerator)

// Wall Actor reply
case class Connected(enumerator: Enumerator[JsValue], prevMessages: Enumerator[JsValue])
case class CannotConnect(msg: String)

// Record used for tracking text change (cache)
case class Record(timestamp: Long, sheetId: Long, baseText: String, resultText: String, consolidated: Operation, conn: Enumerator[JsValue])

// Wall System (Delegate + Actor)
object WallSystem {
  val shutdownInitiateTimeout = 60 * 1000
  val shutdownFinalizeTimeout = 70 * 1000
  // Used for http requests
  val volatileEnumerator: Enumerator[JsValue] = Enumerator.eof

  implicit val timeout = Timeout(1 second)
  lazy val actor = Akka.system.actorOf(Props(new WallSystem))

  def establish(wallId: Long, userId: Long, timestamp: Long): Future[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

    val joinResult = actor ? JoinWall(wallId, userId, timestamp)

    joinResult.map {
      case Connected(producer, prevMessages) =>
        // Create an Iteratee to consume the feed
        val consumer: Iteratee[JsValue, Unit] = Iteratee.foreach[JsValue] { json: JsValue =>
          Logger.info("received: " + json.toString)
          actor ! ActionInWall(wallId, json, ActionDetail(userId, json), producer)
        }.mapDone { _ =>
          actor ! QuitWall(wallId, userId, producer)
        }

        (consumer, prevMessages >>> producer)

      case CannotConnect(error) =>
        // A finished Iteratee sending EOF
        val consumer = Done[JsValue, Unit]((), Input.EOF)
        // Send an error and close the socket
        val producer = Enumerator[JsValue](Json.obj("error" -> error)).andThen(Enumerator.enumInput(Input.EOF))

        (consumer, producer)
      case msg @ _ =>
        // A finished Iteratee sending EOF
        val consumer = Done[JsValue, Unit]((), Input.EOF)
        // Send an error and close the socket
        val producer = Enumerator[JsValue](Json.obj("error" -> "error")).andThen(Enumerator.enumInput(Input.EOF))
        Logger.info("Unhandled message:" + msg.toString)
        (consumer, producer)

    }
  }

  def submitVolatileAction(wallId: Long, userId: Long, timestamp: Long) = {

  }
}

class WallSystem extends Actor {

  implicit val timeout = Timeout(1 second)

  var walls: Map[Long, (ActorRef, Long)] = Map()

  def wall(wallId: Long): ActorRef = {
    walls.get(wallId) match {
      case Some(wall) =>
        walls = walls + (wallId -> (wall._1, System.currentTimeMillis()))
        wall._1
      case None =>
        val newActor = context.actorOf(Props(new WallActor(wallId)))
        walls = walls + (wallId -> (newActor, 0))
        Logger.info("initiated wall actor (" + wallId + ")")
        newActor
    }
  }

  def lastAccessedTime(wallId: Long): Long = {
    walls.get(wallId) match {
      case Some(wall) =>
        wall._2
      case None =>
        0
    }
  }

  def receive = {
    case JoinWall(wallId, userId, timestamp) =>
      val savedSender = sender
      (wall(wallId) ? Join(userId, timestamp)).map(savedSender ! _)
    case QuitWall(wallId, userId, producer) =>
      val savedSender = sender
      (wall(wallId) ? Quit(userId, producer)).map(savedSender ! _)
    case ActionInWall(wallId, json, detail, producer) =>
      val savedSender = sender
      (wall(wallId) ? Action(json, detail, producer)).map(savedSender ! _)
    case Finishing(wallId) =>
      if (System.currentTimeMillis() - lastAccessedTime(wallId) > WallSystem.shutdownFinalizeTimeout) {
        Logger.info("shutting down wall actor (" + wallId + ") due to inactivity")
        walls = walls - wallId
        akka.pattern.gracefulStop(sender, 1 seconds)(context.system)
      }
      else
        sender ! RetryFinish
  }
}

class WallActor(wallId: Long) extends Actor {

  implicit def toDouble(value: JsValue) = { value.as[Double] }
  implicit def toLong(value: JsValue) = { value.as[Long] }

  // key: userId, values: list of sessions user have
  var connections = Map.empty[Long, List[(PushEnumerator[JsValue], Long)]]
  // trick to track pending messages for each session (session, timestamp, action)
  var recentRecords = List[Record]()
  // shutdown timer activated when no connection is left to the actor
  var shutdownTimer: Option[akka.actor.Cancellable] = None

  def prevLogs(timestamp: Long) = WallLog.list(wallId, timestamp)
  def logMessage(kind: String, basetimestamp: Long, userId: Long, message: String) = WallLog.create(kind, wallId, basetimestamp, userId, message)

  def quit(userId: Long, producer: Enumerator[JsValue]) = {
    // clear sessions for userid. if none exists for a userid, remove userid key.
    connections.get(userId).map { producers =>
      val newProducers = producers.filterNot(_._1 == producer)

      if (newProducers.isEmpty)
        connections = connections - userId
      else
        connections = connections + (userId -> newProducers)

    }
    cleanRecentRecords()

    val numConnections = connections.foldLeft[Int](0) { (num, connection) =>
      num + connection._2.length
    }

    if (numConnections == 0) {
      //start scheduling
      shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) {
        context.parent ! Finishing(wallId)
      })
    }

    Logger.info("Number of active connections for wall(" + wallId + "): " + numConnections)
  }

  def updateTimestamp(userId: Long, ts: Long, origin: Enumerator[JsValue]) = {

    connections.get(userId).map { connectionInfoList =>
      val newConnectionInfoList =

        connectionInfoList.map { connectionInfo =>
          val connection = connectionInfo._1

          if (connection == origin)
            (connection, ts)
          else
            connectionInfo
        }

      connections = connections + (userId -> newConnectionInfoList)
    }
  }

  def cleanRecentRecords() = {
    var minTs: Long = 0
    connections.map { keyvalue =>
      val userId = keyvalue._1
      keyvalue._2.map { pair =>
        if (minTs == 0 || pair._2 < minTs)
          minTs = pair._2
      }
    }

    recentRecords = recentRecords.dropWhile(_.timestamp < minTs)
  }

  def receive = {
    // Join
    case Join(userId, timestamp) => {
      // Create an Enumerator to write to this socket
      val wallActor = self
      lazy val producer: PushEnumerator[JsValue] = Enumerator.imperative[JsValue]()

      val prev = Enumerator(prevLogs(timestamp).map { walllog => WallLog.walllog2Json(walllog) }: _*)

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
        connections = connections + (userId -> (connections.getOrElse(userId, List()) :+ (producer, timestamp)))
        sender ! Connected(producer, prev)
      }
    }
    case RetryFinish =>
      val numConnections = connections.foldLeft[Int](0) { (num, connection) =>
        num + connection._2.length
      }

      if (numConnections == 0) {
        //start scheduling
        shutdownTimer = Some(context.system.scheduler.scheduleOnce(WallSystem.shutdownFinalizeTimeout milliseconds) {
          context.parent ! Finishing(wallId)
        })
      }

    // ACK
    case Action(detail, ack: Ack, origin) =>
      Logger.debug("ack came(" + ack.timestamp + ").")
      updateTimestamp(ack.userId, ack.timestamp, origin)
      cleanRecentRecords()
    // Create Action
    case Action(detail, c: CreateAction, origin) =>
      val sheetId = Sheet.createInit(c.x, c.y, c.width, c.height, c.title, c.contentType, c.content, wallId)
      notifyAll("action", c.timestamp, c.userId, (detail.as[JsObject] ++ Json.obj("id" -> sheetId)).toString, origin)
    // Other Action
    case Action(detail, action: ActionDetailWithId, origin) =>
      Sheet.findById(action.id) map { sheet =>

        action match {
          case a: MoveAction =>
            Sheet.move(a.id, a.x, a.y)
          case a: ResizeAction =>
            Sheet.resize(a.id, a.width, a.height)
          case a: RemoveAction =>
            Sheet.delete(a.id)
          case a: SetTitleAction =>
            Sheet.setTitle(a.id, a.title)
          case a: SetTextAction =>
            Sheet.setText(a.id, a.text)
          case a: AlterTextAction =>
            // simulate consolidation of records after timestamp
            val records = recentRecords.filter(r => r.sheetId == a.id && r.timestamp > a.timestamp)
            var pending = a.operations // all mine with > a.timestamp
            assert(pending.size - 1 == records.filter(_.conn == origin).size,
              "pending:" + (pending.size - 1) + " record:" + records.filter(_.conn == origin).size)
            records.map { r =>
              if (r.conn == origin) {
                // consolidated
                pending = pending.drop(1)
              }
              else { // apply arrived consolidated record
                val ss = new StringWithState(r.baseText)
                ss.apply(r.consolidated, 1)
                pending = pending.map { p =>
                  OperationWithState(ss.apply(p.op, 0), p.msgId)
                }
                Logger.debug("simulation: " + ss.text)
              }
            }

            val alteredAction = pending.head.op
            val (baseText, resultText) = Sheet.alterText(a.id, alteredAction.from, alteredAction.length, alteredAction.content)
            val newAction = AlterTextAction(a.userId, a.timestamp, a.id, List(OperationWithState(alteredAction, a.operations.last.msgId)))
            val timestamp = notifyAll("action", action.timestamp, action.userId, newAction.singleJson.toString, origin)

            recentRecords = recentRecords :+ Record(timestamp, a.id, baseText, resultText, alteredAction, origin)

          case a: SetLinkAction =>
            SheetLink.create(a.id, a.to_id, wallId)
          case a: RemoveLinkAction =>
            SheetLink.remove(a.id, a.to_id, wallId)
            SheetLink.remove(a.to_id, a.id, wallId)
        }

        action match {
          case a: AlterTextAction =>
          case _ =>
            notifyAll("action", action.timestamp, action.userId, detail.toString, origin)
        }
      }

    // Quit
    case Quit(userId, producer) => {
      quit(userId, producer)
      notifyAll("userQuit", 0, userId, "", producer)
    }

  }

  def notifyAll(kind: String, basetimestamp: Long, userId: Long, detail: String, origin: Enumerator[JsValue]) = {

    val username = User.findById(userId).get.email
    val logId = logMessage(kind, basetimestamp, userId, detail)
    val msg = Json.obj(
      "kind" -> kind,
      "username" -> username,
      "detail" -> detail,
      "timestamp" -> logId
    )

    // notify all producers
    connections.foreach {
      case (_, producers) =>
        producers.map { producerPair =>
          val producer = producerPair._1
          if (producer == origin)
            producer.push(msg ++ Json.obj("mine" -> true, "timestamp" -> logId))
          else
            producer.push(msg ++ Json.obj("timestamp" -> logId))
        }
    }

    logId
  }

}
