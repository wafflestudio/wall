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

case class Join(userId: String, timestampOpt:Option[Long])
case class Quit(userId: String, producer: Enumerator[JsValue])
case class Talk(userId: String, connectionId:Int, text: String)
case class NotifyJoin(userId: String, connectionId:Int)
case class GetPrevMessages(startTs: Long, endTs: Long)

case class Connected(enumerator: Enumerator[JsValue], prev: Enumerator[JsValue])
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
  
  def prevMessages(roomId: String, startTs: Long, endTs: Long) = {
    (room(roomId) ? GetPrevMessages(startTs, endTs)).mapTo[JsValue]
  }

}

class ChatRoomActor(roomId: String) extends Actor {

  val connectionUsage = new UsageSet
  private var connections = List.empty[(String, PushEnumerator[JsValue], Int)]

  def prevMessages(timestampOpt: Option[Long]) = {
    timestampOpt match {
      case Some(timestamp) =>
        ChatLog.list(roomId, timestamp).map(_.frozen)
      case None => 
        ChatLog.list(roomId).map(_.frozen)
    }
  }
  
  def prevMessages(startTs: Long, endTs: Long) = {
    ChatLog.list(roomId, startTs, endTs).map(_.frozen)
  }

  def logMessage(kind: String, userId: String, message: String) = {
    val when = System.currentTimeMillis
    (ChatLog.create(kind, roomId, userId, message, when).frozen.timestamp, when)
  }

  def receive = {

    case Join(userId, timestampOpt) => {
     
      if (false /* maximum connection per user constraint here*/ ) {
        sender ! CannotConnect("You have reached your maximum number of connections.")
      }
      else {
        
        val connectionId = connectionUsage.allocate
        // Create an Enumerator to write to this socket
        val producer = Enumerator.imperative[JsValue](onStart = () => self ! NotifyJoin(userId, connectionId))
        // previous messages
        val prev = Enumerator(prevMessages(timestampOpt).map { chatlog => ChatLog.toJson(chatlog) }: _*)
        
        connections = connections :+ (userId, producer, connectionId)
    
        // welcome message with connection id
        Logger.info(connections.toString)
        val welcome:Enumerator[JsValue] = Enumerator(Json.obj(
          "kind" -> "welcome",
          "connectionId" -> connectionId,
          "users" -> connections.flatMap { connection => 
            User.findById(connection._1).map(_.frozen).map { user =>
              Json.obj(
                "userId" -> user.id,
                "connectionId" -> connection._3,
                "email" -> user.email,
                "nickname" -> user.nickname
              )
            }
          }
        
        ))
     
        ChatRoom.addUser(roomId, userId)
        sender ! Connected(producer, prev >>> welcome)
      }
    }
    
    case GetPrevMessages(startTs, endTs) =>
      val prev = prevMessages(startTs, endTs).map { chatlog => ChatLog.toJson(chatlog) }
      sender ! JsArray(prev)

    case NotifyJoin(userId, connectionId) => {
      val nickname = User.findById(userId).map(_.frozen).get.nickname
      notifyAll("join", userId, connectionId, "has entered")
    }

    case Talk(userId, connectionId:Int, text) => {
      notifyAll("talk", userId, connectionId, text)
    }

    case Quit(userId, producer) => {
      connections = connections.filterNot{ p => p._1 == userId && p._2 == producer }
       
      ChatRoom.removeUser(roomId, userId)
      notifyAll("quit", userId, 0, "has left")
    }

  }

  def notifyAll(kind: String, userId: String, connectionId: Int, message: String) {

    val user = User.findById(userId).map(_.frozen).get
    val email = user.email
    val nickname = user.nickname
    
    val msg:JsValue = kind match {
      case "talk" =>
        Json.obj(
          "kind" -> kind,
          "userId" -> userId,
          "email" -> email,
          "message" -> message,
          "connectionId" -> connectionId
        )

      case "join" =>  
        val connectionCountForUser = connections.count(_._1 == userId)
        
        Json.obj(
          "kind" -> kind,
          "userId" -> userId,
          "email" -> email,
          "nickname" -> nickname,
          "message" -> Json.obj("nickname" -> nickname, "numConnections" -> connectionCountForUser).toString,
          "connectionId" -> connectionId
        )
      case "quit" =>
        val connectionCountForUser = connections.count(_._1 == userId)
        
        Json.obj(
          "kind" -> kind,
          "userId" -> userId,
          "email" -> email,
          "message" -> Json.obj("numConnections" -> connectionCountForUser).toString
        )
    }
    
    val (timestamp, when) = logMessage(kind, userId, (msg \ "message").as[String])
  
    connections.foreach {
      case (_, producer,_) => producer.push(msg.as[JsObject] ++ Json.obj("timestamp" -> timestamp, "when" -> when))
    }
  }
}
