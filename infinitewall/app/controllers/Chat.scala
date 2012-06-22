package controllers

import play.api.mvc.Controller
import play.api.mvc.Action
import play.api.mvc.WebSocket
import play.api.libs.iteratee._
import akka.actor._
import akka.pattern.ask
import akka.util.duration._
import akka.util.Timeout
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.mvc.Result
import play.api.libs.json._
import play.api.libs.json.DefaultWrites
import java.util.Date
import java.text.SimpleDateFormat
import java.util.Locale
import play.api.Logger
import chat._


object Chat extends Controller with Login {

	implicit val actorTimeout = Timeout(2 second)

	lazy val chatActor = Akka.system.actorOf(Props[ChatSystem])

	//	def index = WebSocket.async[String] { implicit request =>
	//		val enumerator = defaultRoom ? Join(request.session.get("current_user").getOrElse(""))
	//		
	//	}

	def send(message: String) = AuthenticatedAction { implicit request =>
		chatActor ! TalkAt(0, currentUser, message, new Date())
		Ok("")
	}

	def retrieve(timestamp: Int) = AuthenticatedAction { implicit request =>
		val answer = (chatActor ? AskAt(0, currentUser, timestamp)).asPromise.map {
			case Hold(promise) => promise
			case PrevMessages(redeemedMsgs) => redeemedMsgs
		}

		Async {
			answer.flatMap(promiseOfMessages =>
				promiseOfMessages.orTimeout("No new messages, try again", 30000).map { messagesOrTimeout =>
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
