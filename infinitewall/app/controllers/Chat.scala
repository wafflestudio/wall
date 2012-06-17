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


case class Talk(val message: String)

case class Join(email: String)
case class Quit(email: String)

case class Ask(email:String, timestamp:Int)
case class Done(email:String)

case class Hold(enumerator:Enumerator[String])
case class PrevMessages(messages:Enumerator[String])

case class Connected(enumerator:Enumerator[String])

class ChatRoom extends Actor {

	var messages:List[String] = List()
	var websockets = Map.empty[String, PushEnumerator[String]]
	var waiters = Map.empty[String, PushEnumerator[String]]
	
	

	def receive = {
		// websocket
		case Join(email) =>
			val enumerator = Enumerator.imperative[String]()
			websockets = websockets + (email -> enumerator)
			sender ! Connected(enumerator)
		case Quit(email) =>
			websockets = websockets - email
			
		// long-polling
		case Ask(email, timestamp) =>
			if(messages.drop(timestamp).isEmpty)
			{	
				val enumerator = Enumerator.imperative[String]()
				waiters = waiters + (email -> enumerator)
				sender ! Hold(enumerator)
			}
			else {
				val enumerator = Enumerator(messages : _*)
				sender ! PrevMessages(enumerator)
			}			
		case Done(email) =>
			waiters = waiters - email
			
		case Talk(msg) =>
			messages = messages :+ msg
			notifyAll(msg)
	}

	def notifyAll(msg: String) = {
		websockets.foreach {
			case (_, producer) => producer.push(msg)
		}
	}
}


object Chat extends Controller with Login{

	implicit val actorTimeout = Timeout(2 second)
	
	lazy val defaultRoom = {
		Akka.system.actorOf(Props[ChatRoom])
	}
	
//	def index = WebSocket.async[String] { implicit request =>
//		val enumerator = defaultRoom ? Join(request.session.get("current_user").getOrElse(""))
//		
//	}

	def send(message:String) = AuthenticatedAction { implicit request =>
		defaultRoom ! Talk(message) 
		Ok("")
	}

	def retrieve(timestamp:Int) = AuthenticatedAction { implicit request =>
		val answer = defaultRoom ? Ask(request.session.get("current_user").getOrElse(""), timestamp)
		val promiseOfEnumerator = answer.asPromise.map {
			case Hold(enumerator) => enumerator
			case PrevMessages(msgs) => msgs
		}
		
		Async {
			promiseOfEnumerator.orTimeout("Oops", 30000).map { valueOrTimeout =>
				valueOrTimeout.fold(
					messages => Ok.stream(messages andThen Enumerator.eof),
					timeout => InternalServerError(timeout)
				)
			}
		}
	}
}