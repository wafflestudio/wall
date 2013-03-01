package worksheet

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
case class Connected(enumerator:Enumerator[Message])
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
  val (enumerator, channel) = Concurrent.broadcast[Message]
  var log:List[Message] = List()

  def receive = {
    case Join =>
      val prevMessages = Enumerator(log: _*)
      sender ! Connected(prevMessages.andThen(enumerator))
    case msg:Message =>

      println("message arrived to server: " + msg.toString)
      channel.push(msg)

  }
}


object Client {

  def add(id:Int) = {
    Server.join().map {
      case Connected(channel) =>
        println(s"client$id connected")
        new Client("client" + id, channel)

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

  "Play broadcast Enumerator" should {

    "be able to be interleaved" in {
      running(FakeApplication()) {
        // create clients by instantiating Client
        // register clients to server
        Client.add(1).map { client =>
          client.say("i'm client 1")
        }
        Client.add(2).map { client =>
          client.say("i'm client 2")
        }
        Thread.sleep(1000)

        Client.add(3).map { client =>
          client.say("i'm client 3")
        }
        Thread.sleep(1000)

        Client.add(4).map { client =>
          client.say("i'm client 4")
        }
        Thread.sleep(5000)

        "Hello world" must endWith("world")
      }
    }
  }


}



