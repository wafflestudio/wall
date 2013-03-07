package chat

import play.api.libs.iteratee._
import akka.actor._
import play.api.libs.concurrent.Execution.Implicits._
import scala.concurrent.duration._
import akka.pattern.ask
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.mvc.Result
import java.util.Date
import java.text.SimpleDateFormat
import java.util.Locale
import play.api.Logger
import play.api.libs.json._
import models.User
import models.ChatLog
import models.ChatRoom
import java.sql.Timestamp
import scala.concurrent.Future
import akka.util.Timeout
import scala.collection.mutable.BitSet
import utils.UsageSet

case class Join(userId: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Talk(userId: Long, connectionId:Int, text: String)
case class NotifyJoin(userId: Long, connectionId:Int)

case class Connected(enumerator: Enumerator[JsValue], prev: Enumerator[JsValue])
case class CannotConnect(msg: String)

case class Message(kind: String, username: String, text: String)

object ChatSystem {

  implicit val timeout = Timeout(1 second)

  var rooms: Map[Long, ActorRef] = Map()

  def room(roomId: Long): ActorRef = {
    rooms.get(roomId) match {
      case Some(room) => room
      case None =>
        val newRoom = Akka.system.actorOf(Props(new ChatRoomActor(roomId)))
        rooms = rooms + (roomId -> newRoom)
        newRoom
    }
  }

  def establish(roomId: Long, userId: Long, timestamp: Long): Future[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

    val joinResult = room(roomId) ? Join(userId)

    joinResult.map {
      case Connected(producer, prev) =>
        // Create an Iteratee to consume the feed
        val consumer = Iteratee.foreach[JsValue] { event: JsValue =>
          room(roomId) ! Talk(userId, (event \ "connectionId").as[Int], (event \ "text").as[String])
        }.mapDone { _ =>
          room(roomId) ! Quit(userId, producer)
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

}

class ChatRoomActor(roomId: Long) extends Actor {

  val connectionUsage = new UsageSet
  private var connections = List.empty[(Long, PushEnumerator[JsValue], Int)]

  def prevMessages(timestamp: Long) = {
    ChatLog.list(roomId, timestamp)
  }

  def logMessage(kind: String, userId: Long, message: String) = {
    ChatLog.create(kind, roomId, userId, message)
  }

  def receive = {

    case Join(userId) => {
     
      if (false /* maximum connection per user constraint here*/ ) {
        sender ! CannotConnect("You have reached your maximum number of connections.")
      }
      else {
        
        val connectionId = connectionUsage.allocate
        // Create an Enumerator to write to this socket
        val producer = Enumerator.imperative[JsValue](onStart = () => self ! NotifyJoin(userId, connectionId))
        // previous messages
        val prev = Enumerator(prevMessages(0).map { chatlog => ChatLog.chatlog2Json(chatlog) }: _*)
        // TODO: add latest user list in welcome message
        // welcome message with connection id
        val welcome:Enumerator[JsValue] = Enumerator(Json.obj(
          "kind" -> "welcome",
          "connectionId" -> connectionId
        ))
        
        connections = connections :+ (userId, producer, connectionId)

        ChatRoom.addUser(roomId, userId)
        sender ! Connected(producer, prev >>> welcome)
      }
    }

    case NotifyJoin(userId, connectionId) => {
      val nickname = User.findById(userId).get.nickname
      notifyAll("join", userId, connectionId, "has entered")
    }

    case Talk(userId, connectionId:Int, text) => {
      notifyAll("talk", userId, connectionId, text)
    }

    case Quit(userId, producer) => {
      connections = connections.flatMap { p =>
        if (p._1 == userId && p._2 == producer)
          None
        else
          Some(p)
      }
      ChatRoom.removeUser(roomId, userId)
      notifyAll("quit", userId, 0, "has left")
    }

  }

  def notifyAll(kind: String, userId: Long, connectionId: Int, message: String) {

    val user = User.findById(userId)
    val username = user.get.email
    val nickname = user.get.nickname

    val msg = kind match {
      case "talk" =>
        Json.obj(
          "kind" -> kind,
          "connectionId" -> connectionId,
          "username" -> username,
          "message" -> message
        )

      case "join" =>
        val joinMsg = Json.obj(
          "kind" -> kind,
          "username" -> username,
          "connectionId" -> connectionId,
          "nickname" -> nickname,
          "picture" -> user.get.picturePath.getOrElse("").replaceFirst("public/", "/assets/")
        )
        val users = Json.obj("users" -> Json.arr(
          connections.map(i => {
            val user = User.findById(i._1)
            Json.obj(
              "email" -> user.get.email,
              "nickname" -> user.get.nickname,
              "picture" -> user.get.picturePath.getOrElse("").replaceFirst("public/", "/assets/")
            )
          })))
        
        // TODO: users + joinMsg only for the needed connections 
        (joinMsg ++ users)

      case "quit" =>
        Json.obj(
          "kind" -> kind,
          "username" -> username
        )
    }

    logMessage(kind, userId, message)

    connections.foreach {
      case (_, producer,_) => producer.push(msg)
    }
  }
}
