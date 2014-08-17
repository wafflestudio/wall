package controllers

import scala.concurrent.Future
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.iteratee._
import play.api.libs.json.{ JsValue, Json }
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import play.api.mvc.WebSocket
import services.EntryService
import play.Logger

object ServiceController extends Controller with SecureSocial {

	def establish() = securedWebsocket { implicit request =>
		val user = currentUser.get
		Future(EntryService.establish(user.identityId.userId))
	}

	// http send by client
	def speak(wallId: String) = securedAction { implicit request =>
		val uuid = queryParam("uuid")
		Logger.info(s"speak1: ${bodyText}")
		val action = Json.parse(Json.parse(bodyText).as[String])
		Logger.info(s"speak2: $action")
		//		WallService.submit(wallId, request.user.identityId.userId, uuid, 0, action)
		Ok("")
	}

	// http receive
	def listen(wallId: String) = TODO /*SecuredAction.async { implicit request =>
		import play.api.templates.Html
		import play.api.libs.concurrent.Execution.Implicits._
		val uuid = queryParam("uuid")
		val timestamp = queryParam("timestamp").toLong
		val user = request.user

//		WallService.establish(wallId, user.identityId.userId, uuid, timestamp).map { channels =>
//			// force disconnect after 3 seconds
//			val timeoutEnumerator: Enumerator[JsValue] = Enumerator.generateM[JsValue] {
//				Promise.timeout(Some(JsNumber(0)), 3.seconds)
//			}.mapInput {
//				case _ => Input.EOF
//			}
//			timeoutEnumerator.apply(channels._1)
//			// convert to comet stream
//			val stream = channels._2 &> Comet(callback = "triggerOnReceive")
//			Ok.chunked(stream)
//		}

	}*/

	/*
	def prevMessages(roomId: String) = SecuredAction.async { implicit request =>

		// mandatory params
		val startTs: Long = queryParam("startTs").toLong
		val endTs: Long = queryParam("endTs").toLong

		ChatService.prevMessages(roomId, startTs, endTs).map { json =>
			Ok(json)
		}
	}
*/
}
