package controllers

import scala.concurrent.Future

import chat.ChatSystem
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.iteratee._
import play.api.libs.json.{ JsValue, Json }
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import play.api.mvc.WebSocket

object ChatController extends Controller with SecureSocial {

	// /* For development purpose. Not for production use: */
	//
	//	val createForm = Form(
	//		"title" -> nonEmptyText
	//	)
	/*
	def index = SecuredAction { implicit request =>
		val rooms = ChatRoom.list()
		Ok(views.html.chat.index(rooms))
	}

	def room(roomId: Long) = SecuredAction { implicit request =>
		Ok(views.html.chat.room(roomId))
	}

	def create = Action { implicit request =>
		val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
		val title = params.get("title").getOrElse(Seq("untitled"))
		val roomId = ChatRoom.create(title(0))
		Redirect(routes.Chat.room(roomId))
	}

	def destroy = Action {
		Ok("")
	}
*/

	def establish(roomId: String) = WebSocket.async[JsValue] { implicit request =>
		val timestamp: Long = queryParams.getOrElse("timestamp", Seq("0")).head.toLong

		currentUser match {
			case Some(user) =>
				ChatSystem.establish(roomId, user.identityId.userId, Some(timestamp))
			case None =>
				val consumer = Done[JsValue, Unit]((), Input.EOF)
				val producer = Enumerator[JsValue](Json.obj("error" -> "Unauthorized")).andThen(Enumerator.enumInput(Input.EOF))

				Future.successful(consumer, producer)
		}
	}

	def prevMessages(roomId: String) = SecuredAction.async { implicit request =>

		// mandatory params
		val startTs: Long = queryParam("startTs").toLong
		val endTs: Long = queryParam("endTs").toLong

		ChatSystem.prevMessages(roomId, startTs, endTs).map { json =>
			Ok(json)
		}
	}

}