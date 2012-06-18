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

case class Talk(val message: String)

case class Join(email: String)
case class Quit(email: String)

case class Ask(email: String, timestamp: Int)

case class Hold(promise: Promise[List[String]])
case class PrevMessages(messages: Promise[List[String]])

case class Connected(enumerator: Enumerator[String])

class ChatRoom extends Actor {

	var messages: List[String] = List()
	var websockets = Map.empty[String, PushEnumerator[String]]
	var waiters: List[RedeemablePromise[List[String]]] = List()

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
			val prevMessages = messages.drop(timestamp)
			if (prevMessages.isEmpty) {
				val promise = Promise[List[String]]()
				waiters = waiters :+ promise
				sender ! Hold(promise)
			} else {
				val promise = Promise.pure(prevMessages)
				sender ! PrevMessages(promise)
			}

		case Talk(msg) =>
			messages = messages :+ msg
			notifyAll(msg)
	}

	def notifyAll(msg: String) = {
		websockets.foreach {
			case (_, producer) => producer.push(msg)
		}
		waiters.foreach { promise =>
			promise.redeem(List(msg))
		}
		waiters = List.empty
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
		defaultRoom ! Talk(message)
		Ok("")
	}

	def retrieve(timestamp: Int) = AuthenticatedAction { implicit request =>
		val answer = (defaultRoom ? Ask(request.session.get("current_user").getOrElse(""), timestamp)).asPromise.map {
			case Hold(promise) => promise
			case PrevMessages(redeemedMsgs) => redeemedMsgs
		}

		Async {
			answer.await(1000).fold(
				error => Promise.pure(InternalServerError(error.toString)),
				promiseOfMessages => promiseOfMessages.orTimeout("No new messages, try again", 30000).map { messagesOrTimeout =>
					messagesOrTimeout.fold(
						messages => Ok(Json.toJson(messages)),
						timeout => Ok(""))
				})
		}
	}
}
