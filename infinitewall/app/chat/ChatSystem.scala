package chat

import play.api.libs.iteratee._
import akka.actor._
import akka.util.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.mvc.Result
import java.util.Date
import java.text.SimpleDateFormat
import java.util.Locale
import play.api.Logger

/** ChatRoom messages **/ 
case class Talk(userId: Long, message: String, time: Date)
case class Join(userId: Long)
case class Quit(userId: Long)
case class Ask(userId: Long, timestamp: Int)
/** ChatRoom answers **/
case class ChatLog(email: String, message: String, time: Date)
case class Hold(promise: Promise[List[Talk]])
case class PrevMessages(messages: Promise[List[Talk]])
case class Connected(enumerator: Enumerator[Talk])

class ChatRoom(val roomId: Long) extends Actor {

	var messages: List[Talk] = List()
	
	var websockets = Map.empty[Long, PushEnumerator[Talk]]
	var waiters: List[RedeemablePromise[List[Talk]]] = List()
	
	def currentUsers = models.ChatRoom.listUsers(roomId)
	def ensureJoined(userId:Long) = models.ChatRoom.addUser(roomId, userId)
	def removeUser(userId:Long) = models.ChatRoom.removeUser(roomId, userId)

	def receive = {
		// websocket
		case Join(userId) =>
			val enumerator = Enumerator.imperative[Talk]()
			websockets = websockets + (userId -> enumerator)
			ensureJoined(userId)
			
			sender ! Connected(enumerator)
		case Quit(userId) =>
			removeUser(userId)
			websockets = websockets - userId

		// long-polling
		case Ask(userId, timestamp) =>
			ensureJoined(userId)
			
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

		case talk @ Talk(by, msg, time) =>
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


/** ChatSystem messages **/
case class TalkAt(roomId: Long, userId: Long, message: String, time: Date)
case class AskAt(roomId: Long, userId: Long, timestamp: Int)

/** ChatSystem answers **/
case class RoomState(actorRef: ActorRef, sweepSchedule: Cancellable)
case class Closing(roomId: Long)


class ChatSystem extends Actor {

	implicit val actorTimeout = Timeout(2 second)
	var rooms = Map[Long, ActorRef]()

	def getOrOpenRoom(roomId: Long) = {
		rooms.get(roomId) match {
			case Some(room) =>
				room
			case None =>
				val room = context.actorOf(Props(new ChatRoom(roomId)))
				rooms = rooms + (roomId -> room)
				room
		}
	}

	def closeRoom(roomId: Long) = {
		rooms = rooms - roomId
	}

	def receive = {
		case TalkAt(roomId, by, message, time) =>
			val room = getOrOpenRoom(roomId)
			room ! Talk(by, message, time)

		case AskAt(roomId, email, timestamp) =>
			val room = getOrOpenRoom(roomId)
			val answer = room ? Ask(email, timestamp)
			val savedSender = sender
			answer.map { response =>
				response match {
					case Hold(_) | PrevMessages(_) => savedSender ! response
							Logger.debug("message")
					case _ => Logger.debug("!message")
				}
			}
		case Closing(roomId) =>
			closeRoom(roomId)
	}
}
