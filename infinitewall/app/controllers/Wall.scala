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
import models.ChatRoom
import models.WallLog
import models.Sheet
import play.api.db.DB
import models.WallPreference
import models.ResourceTree
import models.RootFolder
import models.RootFolder


object Wall extends Controller with Auth with Login{
	
	def index = AuthenticatedAction { implicit request =>
		val walls = models.Wall.findAllByUserId(currentUserId)
		Ok(views.html.wall.index(walls))
	}
	
	implicit def resourceTree2Json(implicit tree:ResourceTree):JsValue = {
		tree.node match {
			case root:models.RootFolder => 
				JsArray(tree.children.map(resourceTree2Json(_)))
			case folder:models.Folder =>
				JsObject(Seq("type" -> JsString("folder"), "id" -> JsNumber(folder.id.get), "name" -> JsString(folder.name), 
					"children" -> JsArray(tree.children.map(resourceTree2Json(_)))))
			case wall:models.Wall =>
				JsObject(Seq("type" -> JsString("wall"), "id" -> JsNumber(wall.id.get), "name" -> JsString(wall.name)))
		}
	}
	
	
	def tree = AuthenticatedAction { implicit request =>
		val tree = models.Wall.tree(currentUserId)
		Ok(resourceTree2Json(tree))
	}
	
	def stage(wallId: Long) = AuthenticatedAction { implicit request =>
		val wall = models.Wall.findByUserId(currentUserId, wallId)
		wall match {
			case Some(_) =>
				val chatRoomId = ChatRoom.findOrCreateForWall(wallId)
				val (timestamp, sheets) = DB.withTransaction { implicit c => 
					(WallLog.timestamp(wallId), Sheet.findByWallId(wallId))
				}
				val pref = WallPreference.findOrCreate(currentUserId, wallId)
				Ok(views.html.wall.stage(wallId, pref, sheets, timestamp, chatRoomId))
			case None => 
				Forbidden("Request wall with id " + wallId + " not accessible")
		}
		
	}
	
	def create = AuthenticatedAction { implicit request =>
		val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
		val title = params.get("title").getOrElse(Seq("unnamed"))
		val wallId = models.Wall.create(currentUserId, title(0))
		Redirect(routes.Wall.stage(wallId))
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
		models.Wall.deleteByUserId(currentUserId, id)
		Ok(Json.toJson("OK"))
	}
	
	def setView(wallId: Long, panX: Double, panY: Double, zoom: Double) = AuthenticatedAction { implicit request =>
		models.WallPreference.setView(currentUserId, wallId, panX, panY, zoom)
		Ok(Json.toJson("OK"))
	}
	
	def moveTo(wallId:Long, folderId:Long) = AuthenticatedAction { implicit request => 
		
		Ok("")
	}
}