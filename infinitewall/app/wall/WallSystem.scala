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

// Messages
// WallSystem -> WallSystem Actor
case class JoinWall(wallId: String, userId: String, timestamp: Long)
case class QuitWall(wallId: String, userId: String, connectionId:Int)
case class ActionInWall(wallId: String, json: JsValue, detail: ActionDetail, connectionId:Int)
case class Finishing(wallId: String)
case class FinishAccepted()
case class RetryFinish()

// WallSystem Actor -> Wall Actor
case class Join(userId: String, timestamp: Long)
case class Quit(userId: String, connectionId:Int)
case class Action(json: JsValue, detail: ActionDetail, connectionId:Int)

// Wall Actor reply
case class Connected(enumerator: Enumerator[JsValue], prevMessages: Enumerator[JsValue], connectionId:Int)
case class CannotConnect(msg: String)

// Wall System (Delegate + Actor)
object WallSystem {
  val shutdownInitiateTimeout = 60 * 1000
  val shutdownFinalizeTimeout = 70 * 1000
  // Used for http requests
  val volatileEnumerator: Enumerator[JsValue] = Enumerator.eof

  implicit val timeout = Timeout(1 second)
  lazy val actor = Akka.system.actorOf(Props(new WallSystem))

  def establish(wallId: String, userId: String, timestamp: Long, receiveOnly:Boolean = false): Future[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

    val joinResult = actor ? JoinWall(wallId, userId, timestamp)

    joinResult.map {
      case Connected(producer, prevMessages, connectionId) =>
        // Create an Iteratee to consume the feed
        val consumer: Iteratee[JsValue, Unit] = Iteratee.foreach[JsValue] { json: JsValue =>
          Logger.info("received: " + json.toString)
          actor ! ActionInWall(wallId, json, ActionDetail(userId, json), connectionId)
        }.mapDone { _ =>
          actor ! QuitWall(wallId, userId, connectionId)
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

  def submitVolatileAction(wallId: String, userId: String, connectionId:Int, json:JsValue) = {
    actor ? ActionInWall(wallId, json, ActionDetail(userId, json), connectionId)
  }
}

class WallSystem extends Actor {

  implicit val timeout = Timeout(1 second)

  case class WallActorState(actorRef: ActorRef, time: Long)

  var wallActors: Map[String, WallActorState] = Map()

  def wall(wallId: String): ActorRef = {
    wallActors.get(wallId) match {
      case Some(actorState) =>
        wallActors = wallActors + (wallId -> WallActorState(actorState.actorRef, System.currentTimeMillis()))
        actorState.actorRef
      case None =>
        val newActor = context.actorOf(Props(new WallActor(wallId)))
        wallActors = wallActors + (wallId -> WallActorState(newActor, 0))
        Logger.info("initiated wall actor (" + wallId + ")")
        newActor
    }
  }

  def lastAccessedTime(wallId: String): Long = {
    wallActors.get(wallId) match {
      case Some(actorState) =>
        actorState.time
      case None =>
        0
    }
  }

  def receive = {
    case JoinWall(wallId, userId, timestamp) =>
      val savedSender = sender
      (wall(wallId) ? Join(userId, timestamp)).map(savedSender ! _)
    case QuitWall(wallId, userId, connectionId) =>
      val savedSender = sender
      (wall(wallId) ? Quit(userId, connectionId)).map(savedSender ! _)
    case ActionInWall(wallId, json, detail, connectionId) =>
      val savedSender = sender
      (wall(wallId) ? Action(json, detail, connectionId)).map(savedSender ! _)
    case Finishing(wallId) =>
      if (System.currentTimeMillis() - lastAccessedTime(wallId) > WallSystem.shutdownFinalizeTimeout) {
        Logger.info("shutting down wall actor (" + wallId + ") due to inactivity")
        wallActors = wallActors - wallId
        akka.pattern.gracefulStop(sender, 1 seconds)(context.system)
      }
      else
        sender ! RetryFinish
  }
}

