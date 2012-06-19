package controllers

import play.api.mvc.Controller
import play.api.mvc.Action
import play.api.mvc.WebSocket
import play.api.libs.iteratee._
import akka.actor._
import akka.util.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.mvc.Result
import play.api.libs.json._
import play.api.libs.json.DefaultWrites
import java.util.Date
import java.text.SimpleDateFormat
import java.util.Locale

case class Talk(email: String, message: String, time: Date)
case class Join(email: String)
case class Quit(email: String)
case class Ask(email: String, timestamp: Int)
case class Hold(promise: Promise[List[Talk]])
case class PrevMessages(messages: Promise[List[Talk]])

case class Connected(enumerator: Enumerator[Talk])

class ChatRoom extends Actor {

	var messages: List[Talk] = List()
	var websockets = Map.empty[String, PushEnumerator[Talk]]
	var waiters: List[RedeemablePromise[List[Talk]]] = List()

	def receive = {
		// websocket
		case Join(email) =>
			val enumerator = Enumerator.imperative[Talk]()
			websockets = websockets + (email -> enumerator)
			sender ! Connected(enumerator)
		case Quit(email) =>
			websockets = websockets - email

		// long-polling
		case Ask(email, timestamp) =>
			val prevMessages = messages.drop(timestamp)
			if (prevMessages.isEmpty) {
				val promise = Promise[List[Talk]]()
				waiters = waiters :+ promise
				sender ! Hold(promise)
			}
			else {
				val promise = Promise.pure(prevMessages)
				sender ! PrevMessages(promise)
			}

		case Talk(by, msg, time) =>
			val talk = Talk(by, msg, time)
			messages = messages :+ talk
			notifyAll(talk)
	}

	def notifyAll(talk: Talk) = {
		websockets.foreach {
			case (_, producer) => producer.push(talk)
		}
		waiters.foreach { promise =>
			promise.redeem(List(talk))
		}
		waiters = List.empty
	}
}

case class TalkAt(roomId: Long, email: String, message: String, time: Date)
case class AskAt(roomId: Long, email: String, timestamp: Int)
//case class RoomState(actorRef:ActorRef, lastTime:)

class ChatActor extends Actor {

	implicit val actorTimeout = Timeout(2 second)
	var rooms = Map[Long, ActorRef]()

	def getOrCreateRoom(roomId: Long) = {
		rooms.get(roomId) match {
			case Some(room) =>
				room
			case None =>
				val room = context.actorOf(Props[ChatRoom])
				rooms = rooms + (roomId -> room)
				room
		}
	}

	def receive = {
		case TalkAt(roomId, by, message, time) =>
			val room = getOrCreateRoom(roomId)
			room ! Talk(by, message, time)

		case AskAt(roomId, email, timestamp) =>
			val room = getOrCreateRoom(roomId)
			val answer = room ? Ask(email, timestamp)
			answer.map { response =>
				response match {
					case Hold(_) | PrevMessages(_) => sender ! response
				}
			}
		case Terminated(actorRef) =>
			
	}
}

object Chat extends Controller with Login {

	implicit val actorTimeout = Timeout(2 second)

	lazy val defaultRoom = {
		Akka.system.actorOf(Props[ChatRoom])
	}

	//	def index = WebSocket.async[String] { implicit request =>
	//		val enumerator = defaultRoom ? Join(request.session.get("current_user").getOrElse(""))
	//		
	//	}

	def send(message: String) = AuthenticatedAction { implicit request =>
		defaultRoom ! Talk(currentUser, message, new Date())
		Ok("")
	}

	def retrieve(timestamp: Int) = AuthenticatedAction { implicit request =>
		val answer = (defaultRoom ? Ask(currentUser, timestamp)).asPromise.map {
			case Hold(promise) => promise
			case PrevMessages(redeemedMsgs) => redeemedMsgs
		}

		Async {
			answer.await(1000).fold(
				error => Promise.pure(InternalServerError(error.toString)),
				promiseOfMessages => promiseOfMessages.orTimeout("No new messages, try again", 30000).map { messagesOrTimeout =>
					messagesOrTimeout.fold(
						messages => Ok(Json.toJson(messages.map { message =>
							Map("by" -> message.email,
								"message" -> message.message,
								"time" -> new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.US).format(message.time))
						})),
						timeout => Ok(Json.toJson(List[String]())))
				})
		}
	}

}
