package services.wall

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
import services.EntryMessage
import services.TerminateAt
import services.TerminateConnection
import services.ServiceMessage

// Wall System (Delegate + Actor)

object WallService {
	val shutdownFinalizeTimeout = 70 * 1000
	/*
	// Used for http requests
	val volatileEnumerator: Enumerator[JsValue] = Enumerator.eof

	implicit val timeout = Timeout(1 second)
	lazy val wallSystem = Akka.system.actorOf(Props(new WallService))

	def establish(wallId: String, userId: String, uuid: String, timestamp: Long, syncOnce: Boolean = false): Future[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

		val joinResult = wallSystem ? JoinWall(wallId, userId, uuid, timestamp, syncOnce)

		joinResult.map {
			case Connected(producer, prevMessages, connectionId) =>
				// Create an Iteratee to consume the feed
				val consumer: Iteratee[JsValue, Unit] = Iteratee.foreach[JsValue] { json: JsValue =>
					Logger.debug("received: " + json.toString)
					wallSystem ! ActionInWall(wallId, userId, uuid, connectionId, json)
				}.map { _ =>
					wallSystem ! QuitWall(wallId, userId, uuid, connectionId, syncOnce)
				}

				(consumer, prevMessages >>> producer)

			case CannotConnect(error) =>
				// A finished Iteratee sending EOF
				val consumer = Done[JsValue, Unit]((), Input.EOF)
				// Send an error and close the socket
				val producer = Enumerator[JsValue](Json.obj("error" -> error)).andThen(Enumerator.enumInput(Input.EOF))
				(consumer, producer)
		}
	}

	def submit(wallId: String, userId: String, uuid: String, connectionId: Int, actionJson: JsValue) = {
		Logger.info(actionJson.toString)
		wallSystem ? ActionInWall(wallId, userId, uuid, connectionId, actionJson)
	}
	* 
	*/
}

class WallService extends Actor {

	implicit val timeout = Timeout(1 second)

	/* shutdown time: system and actor should both agree on stopping an inactivate actor
	 * 1) actor detects inactivity  
	 * 2) actor starts shutdown timer
	 * 3) when the timer expires, actor sends 'Finishing' 
	 * 4) whilst, system keeps track of access time to the actor
	 * 5) 	system makes sure no messages were came for the actor for the given time frame
	 * 6) when both inactive times are expired, the actor is safe for removal
	 * 	otherwise, shutdown is retried or canceled
	*/
	case class WallActorState(actorRef: ActorRef, time: Long)

	var wallActors: Map[String, WallActorState] = Map()

	def wallActor(wallId: String): ActorRef = {
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
		// find room by id
		// send the message to the room actor
		case EntryMessage(userId, channel, path, content, _) =>
			val wallId = path.head
			wallActor(wallId) ! ServiceMessage(userId, channel, content)
		case TerminateAt(userId, channel, path) =>
			val wallId = path.head
			wallActor(wallId) ! TerminateConnection(userId, channel)
	}
}

