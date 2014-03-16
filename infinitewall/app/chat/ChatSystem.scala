package chat

import scala.concurrent.Future
import scala.concurrent.duration._

import akka.actor._
import akka.pattern.ask
import akka.util.Timeout
import play.api.Play.current
import play.api.libs.concurrent._
import play.api.libs.concurrent.Execution.Implicits._

import play.api.libs.iteratee._
import play.api.libs.json._

case class Join(userId: String, timestampOpt: Option[Long])
case class Quit(userId: String, producer: Enumerator[JsValue], connectionId: Int)
case class Talk(userId: String, connectionId: Int, text: String)
case class NotifyJoin(userId: String, connectionId: Int)
case class GetPrevMessages(startTs: Long, endTs: Long)

case class Connected(enumerator: Enumerator[JsValue], prev: Enumerator[JsValue], connectionId: Int)
case class CannotConnect(msg: String)

case class Message(kind: String, email: String, text: String)

// FIXME: check for any concurrency issue especially accessing rooms
object ChatSystem {

	implicit val timeout = Timeout(1 second)

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

	def establish(roomId: String, userId: String, timestamp: Option[Long]): Future[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

		val joinResult = room(roomId) ? Join(userId, timestamp)

		joinResult.map {
			case Connected(producer, prev, connectionId) =>
				// Create an Iteratee to consume the feed
				val consumer = Iteratee.foreach[JsValue] { event: JsValue =>
					room(roomId) ! Talk(userId, (event \ "connectionId").as[Int], (event \ "text").as[String])
				}.mapDone { _ =>
					room(roomId) ! Quit(userId, producer, connectionId)
				}

				(consumer, prev >>> producer)

			case CannotConnect(error) =>

				// Connection error

				// A finished Iteratee sending EOF
				val consumer = Done[JsValue, Unit]((), Input.EOF)

				// Send an error and close the socket
				val producer = Enumerator[JsValue](Json.obj("error" -> error)).andThen(Enumerator.enumInput(Input.EOF))

				(consumer, producer)

		}

	}

	def prevMessages(roomId: String, startTs: Long, endTs: Long) = {
		(room(roomId) ? GetPrevMessages(startTs, endTs)).mapTo[JsValue]
	}

}
