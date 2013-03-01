package worksheet.old

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
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
import java.sql.Timestamp
import scala.concurrent.Future
import akka.util.Timeout
import play.api.libs.json.JsValue
import play.api.libs.concurrent._
import scala.concurrent.ExecutionContext.Implicits.global

case class Join()
case class Connected(enumerator:Enumerator[Message], prev:Enumerator[Message])
case class Talk(message:String)
case class Message(kind:Int, from:String, msg:String)

object Server {
  implicit val timeout = Timeout(1 second)
  lazy val actorRef = Akka.system.actorOf(Props[Server], name = "server")

  def join() = {
    actorRef ? Join
  }

  def talk(from:String, msg:String) = {
    actorRef ! Message(0, from, msg)
  }
}

class Server extends Actor
{
  import context.dispatcher
  implicit val timeout = Timeout(1 second)

  var log:List[Message] = List()
  val logEnumerator = Enumerator.imperative[Message]()
//  val logIteratee = Iteratee.foreach[Message](msg => log = log :+ msg)
//  logEnumerator |>> logIteratee
  var connections:List[PushEnumerator[Message]] = List(logEnumerator)

  def receive = {
    case Join =>
      val prevMessages = Enumerator(log: _*)
      val producer = Enumerator.imperative[Message](/*onStart = () => self ! NotifyJoin(userId)*/)
      connections = connections :+ producer

      sender ! Connected(producer, prevMessages)
    case msg:Message =>

      println("message arrived to server: " + msg.toString)
      notifyAll(msg)
      log = log :+ msg
  }

  def notifyAll(msg:Message) = {
    connections.map { c =>
      c.push(msg)
    }
  }


}


object Client {

  def add(id:Int) = {
    Server.join().map {
      case Connected(channel, prev) =>
        println(s"client$id connected")
        new Client("client" + id, prev >>> channel)

    }
  }
}

class Client(val name:String, val serverEnumerator:Enumerator[Message]) {

  val earIteratee = Iteratee.foreach[Message](event => println(s"${name}> Got message '${event.msg}' from ${event.from}"))

  // every time message is broadcasted from server, print the console message
  serverEnumerator |>> earIteratee
  // push enumerator for talking to server

  def say(msg:String) = {
    Server.talk(name, msg)
  }
}


class IterateeSpec extends Specification {

  "Play push enumerator" should {

    "not be lost" in {
      running(FakeApplication()) {
        // create clients by instantiating Client
        // register clients to server
        Client.add(1).map { client =>
          client.say("i'm client 1(1)")
          client.say("i'm client 1(2)")
        }
        Client.add(2).map { client =>
          client.say("i'm client 2(1)")
          client.say("i'm client 2(2)")
        }
        Thread.sleep(100)

        Client.add(3).map { client =>
          client.say("i'm client 3")
        }
        Thread.sleep(100)

        Client.add(4).map { client =>
          client.say("i'm client 4")
        }
        Thread.sleep(5000)

        "Hello world" must endWith("world")
      }
    }
  }


}



