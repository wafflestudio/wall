package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.libs.iteratee._
import play.api.libs.concurrent._
import akka.actor._
import akka.util.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.Play.current
import models.User
import wall.WallSystem


object Wall extends Controller with Auth with Login{
	
	def index = AuthenticatedAction { implicit request =>
		val walls = models.Wall.list
		Ok(views.html.wall.index(walls))
	}
	
	def wall(wallId: Long) = AuthenticatedAction { implicit request =>
		Ok(views.html.wall.wall(wallId))
	}
	
	def create = Action { implicit request =>
		val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
		val title = params.get("title").getOrElse(Seq("unnamed"))
		val wallId = models.Wall.create(currentUserId, title(0))
		Redirect(routes.Wall.wall(wallId))
	}

	def sync(wallId: Long, timestamp:Long = 0) = WebSocket.async[JsValue] { request =>
		request.session.get("current_user_id") match {
			case Some(userId) =>
				WallSystem.establish(wallId, userId.toLong, timestamp)
			case None =>
				val consumer = Done[JsValue, Unit]((), Input.EOF)
				val producer = Enumerator[JsValue](JsObject(Seq("error" -> JsString("Unauthorized")))).andThen(Enumerator.enumInput(Input.EOF))
				Promise.pure(consumer, producer)
		}
	}

	def delete(id: Long) = AuthenticatedAction { implicit request => 
		models.Wall.delete(id)
		Ok(Json.toJson("OK"))
	}
}