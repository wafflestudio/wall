package controllers

import play.api.mvc.Controller
import play.api.mvc.Action
import play.api.mvc.WebSocket
import play.api.mvc.Result
import play.api.libs.json._
import play.api.libs.json.DefaultWrites
import play.api.Logger
import chat._
import play.api.libs.iteratee._
import play.api.libs.concurrent.Akka
import play.api.libs.concurrent.Promise
import models.ChatRoom
import play.api.data._
import play.api.data.Forms._
import play.api.data.validation.Constraints._
import play.api.libs.concurrent.Execution.Implicits._

object Chat extends Controller with Login {

  // /* For development purpose. Not for production use: */
  //
  //	val createForm = Form(
  //		"title" -> nonEmptyText
  //	)
  /*
	def index = AuthenticatedAction { implicit request =>
		val rooms = ChatRoom.list()
		Ok(views.html.chat.index(rooms))
	}

	def room(roomId: Long) = AuthenticatedAction { implicit request =>
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
    val params = request.queryString
    val timestampOpt:Option[Long] = params.get("timestamp").map(_(0).toLong)

    request.session.get("current_user.id") match {
      case Some(id) =>
       ChatSystem.establish(roomId, id, timestampOpt)
      case None =>
        val consumer = Done[JsValue, Unit]((), Input.EOF)
        val producer = Enumerator[JsValue](Json.obj("error" -> "Unauthorized")).andThen(Enumerator.enumInput(Input.EOF))

        Promise.pure(consumer, producer)
    }
  }
  
  def prevMessages(roomId: String) = AuthenticatedAction { implicit request =>
    val params = request.queryString
    // mandatory params
    val startTs:Long = params.get("startTs").get(0).toLong
    val endTs:Long = params.get("endTs").get(0).toLong
    
    Async {
      ChatSystem.prevMessages(roomId, startTs, endTs).map { json =>        
        Ok(json)
      }
    }
  }

}
