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
import securesocial.core.{Identity, Authorization}

object Chat extends Controller with securesocial.core.SecureSocial {

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

 def page = UserAwareAction { implicit request =>
    val userName = request.user match {
        case Some(user) => user.fullName
        case _ => "guest"
    }
     Ok("Hello %s".format(userName))
  }

  def establish(roomId: String) = WebSocket.async[JsValue] { implicit request =>
    val params = request.queryString
    val timestampOpt:Option[Long] = params.get("timestamp").map(_(0).toLong)

    securesocial.core.SecureSocial.currentUser match {
      case Some(user) =>
       ChatSystem.establish(roomId, user.identityId.id, timestampOpt)
      case None =>
        val consumer = Done[JsValue, Unit]((), Input.EOF)
        val producer = Enumerator[JsValue](Json.obj("error" -> "Unauthorized")).andThen(Enumerator.enumInput(Input.EOF))

        Promise.pure(consumer, producer)
    }
  }
  
  def prevMessages(roomId: String) = SecuredAction { implicit request =>
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
