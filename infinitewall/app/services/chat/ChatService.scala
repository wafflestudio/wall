package services.chat

import scala.concurrent.Future
import scala.concurrent.duration._
import akka.actor._
import akka.pattern.ask
import akka.util.Timeout
import play.api.Play.current
import play.api.libs.concurrent._
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.iteratee._
import play.api.libs.iteratee.Concurrent.Channel
import play.api.libs.json._
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import services.EntryMessage
import services.TerminateAt
import services.TerminateConnection
import services.ServiceMessage

class ChatService extends Actor {

	var rooms: Map[String, ActorRef] = Map()

	def room(roomId: String): ActorRef = {
		rooms.get(roomId) match {
			case Some(room) => room
			case None =>
				val newRoom = Akka.system.actorOf(Props(new ChatRoomActor(roomId)))
				rooms = rooms + (roomId -> newRoom)
				newRoom
		}
	}

	def receive = {
		// find room by id
		// send the message to the room actor
		case EntryMessage(userId, channel, path, content, _) =>
			val roomId = path.head
			room(roomId) ! ServiceMessage(userId, channel, content)
		case TerminateAt(userId, channel, path) =>
			val roomId = path.head
			room(roomId) ! TerminateConnection(userId, channel)

	}
}
