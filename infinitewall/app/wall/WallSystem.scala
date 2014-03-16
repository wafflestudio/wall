package wall

import scala.concurrent.Future
import scala.concurrent.duration.DurationInt

import akka.actor._
import akka.pattern.ask
import akka.util.Timeout
import play.api.Logger
import play.api.Play.current
import play.api.libs.concurrent.Akka
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.iteratee.{ Done, Enumerator, Input, Iteratee }
import play.api.libs.json.{ JsValue, Json }
import play.api.libs.json.Json.toJsFieldJsValueWrapper

// Messages
// WallSystem -> WallSystem Actor
case class JoinWall(wallId: String, userId: String, uuid: String, timestamp: Long, syncOnce: Boolean = false)
case class QuitWall(wallId: String, userId: String, uuid: String, connectionId: Int, wasPersistent: Boolean = false)
case class ActionInWall(wallId: String, userId: String, uuid: String, connectionId: Int, actionJson: JsValue)
case class Finishing(wallId: String)
case class FinishAccepted()
case class RetryFinish()

// WallSystem Actor -> Wall Actor
case class Join(userId: String, uuid: String, timestamp: Long, syncOnce: Boolean = false)
case class Quit(userId: String, uuid: String, connectionId: Int, wasPersistent: Boolean = false)
case class Action(json: JsValue, uuid: String, connectionId: Int, parsed: ActionDetail)

// Wall Actor reply
case class Connected(enumerator: Enumerator[JsValue], prevMessages: Enumerator[JsValue], connectionId: Int)
case class CannotConnect(msg: String)

// Wall System (Delegate + Actor)
object WallSystem {
	val shutdownInitiateTimeout = 60 * 1000
	val shutdownFinalizeTimeout = 70 * 1000
	// Used for http requests
	val volatileEnumerator: Enumerator[JsValue] = Enumerator.eof

	implicit val timeout = Timeout(1 second)
	lazy val actor = Akka.system.actorOf(Props(new WallSystem))

	def establish(wallId: String, userId: String, uuid: String, timestamp: Long, syncOnce: Boolean = false): Future[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

		val joinResult = actor ? JoinWall(wallId, userId, uuid, timestamp, syncOnce)

		joinResult.map {
			case Connected(producer, prevMessages, connectionId) =>
				// Create an Iteratee to consume the feed
				val consumer: Iteratee[JsValue, Unit] = Iteratee.foreach[JsValue] { json: JsValue =>
					Logger.debug("received: " + json.toString)
					actor ! ActionInWall(wallId, userId, uuid, connectionId, json)
				}.mapDone { _ =>
					actor ! QuitWall(wallId, userId, uuid, connectionId, syncOnce)
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

	def submitActions(wallId: String, userId: String, uuid: String, connectionId: Int, actionJson: JsValue) = {
		Logger.info(actionJson.toString)
		actor ? ActionInWall(wallId, userId, uuid, connectionId, actionJson)
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
		case JoinWall(wallId, userId, uuid, timestamp, syncOnce) =>
			val savedSender = sender
			(wall(wallId) ? Join(userId, uuid, timestamp, syncOnce)).map(savedSender ! _)
		case QuitWall(wallId, userId, uuid, connectionId, wasPersistent) =>
			val savedSender = sender
			(wall(wallId) ? Quit(userId, uuid, connectionId, wasPersistent)).map(savedSender ! _)
		case ActionInWall(wallId, userId, uuid, connectionId, json) =>
			val savedSender = sender
			(wall(wallId) ? Action(json, uuid, connectionId, ActionDetail(userId, json))).map(savedSender ! _)
		case Finishing(wallId) =>
			if (System.currentTimeMillis() - lastAccessedTime(wallId) > WallSystem.shutdownFinalizeTimeout) {
				Logger.info("shutting down wall actor (" + wallId + ") due to inactivity")
				wallActors = wallActors - wallId
				akka.pattern.gracefulStop(sender, 1 seconds) //(context.system)
			} else
				sender ! RetryFinish
	}
}

