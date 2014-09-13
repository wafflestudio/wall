package controllers

import scala.concurrent.Future
import services.chat.ChatService
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.iteratee._
import play.api.libs.json.{ JsValue, Json }
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import play.api.mvc.WebSocket
import models.ChatRoom
import play.api.mvc.Action
import models.ActiveRecord
import net.fwbrasil.activate.ActivateContext
import net.fwbrasil.activate.entity.Entity

object ChatController extends Controller with SecureSocial {

	def index = SecuredAction { implicit request =>
		val rooms = ChatRoom.list.map(_.frozen)
		Ok(views.html.chat.index(rooms))
	}

	def room(roomId: String) = SecuredAction { implicit request =>
		Ok(views.html.chat.room(roomId))
	}

	def create = Action { implicit request =>
		val title = formParam("title")
		val roomId = ChatRoom.create(title).frozen.id
		Redirect(routes.ChatController.room(roomId))
	}

	def destroy(roomId: String) = Action {
		Ok("")
	}

}
