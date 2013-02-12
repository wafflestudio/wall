package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.libs.iteratee._
import play.api.libs.concurrent._
import akka.actor._
import scala.concurrent.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.Play.current
import models.User
import wall.WallSystem
import models.ChatRoom
import models.WallLog
import models.Sheet
import models.SheetLink
import play.api.db.DB
import models.WallPreference
import models.ResourceTree
import models.RootFolder

object Wall extends Controller with Auth with Login {

	def index = AuthenticatedAction { implicit request =>
		val sharedWalls = models.User.listSharedWalls(currentUserId)
		val nonSharedWalls = models.User.listNonSharedWalls(currentUserId)
		//val walls = models.User.listNonSharedWalls(currentUserId)
		Ok(views.html.wall.index(nonSharedWalls, sharedWalls))
	}

	implicit def resourceTree2Json(implicit tree: ResourceTree): JsValue = {
		tree.node match {
			case root: models.RootFolder =>
				JsArray(tree.children.map(resourceTree2Json(_)))
			case folder: models.Folder =>
				JsObject(Seq("type" -> JsString("folder"), "id" -> JsNumber(folder.id.get), "name" -> JsString(folder.name),
					"children" -> JsArray(tree.children.map(resourceTree2Json(_)))))
			case wall: models.Wall =>
				JsObject(Seq("type" -> JsString("wall"), "id" -> JsNumber(wall.id.get), "name" -> JsString(wall.name)))
		}
	}

	def tree = AuthenticatedAction { implicit request =>
		val tree = models.Wall.tree(currentUserId)
		Ok(resourceTree2Json(tree))
	}

	def stage(wallId: Long) = AuthenticatedAction { implicit request =>
		val wall = models.Wall.findById(wallId)

		wall match {
			case Some(w) =>
				if (models.Wall.isValid(wallId, currentUserId)) {
					val chatRoomId = ChatRoom.findOrCreateForWall(wallId)
					val (timestamp, sheets, sheetlinks) = DB.withConnection { implicit c =>
						(WallLog.timestamp(wallId), Sheet.findByWallId(wallId), SheetLink.findByWallId(wallId))
					}
					val pref = WallPreference.findOrCreate(currentUserId, wallId)
					Ok(views.html.wall.stage(wallId, w.name, pref, sheets, sheetlinks, timestamp, chatRoomId))
				}
				else {
					Forbidden("Request wall with id " + wallId + " not accessible")
				}
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

	def sync(wallId: Long, timestamp: Long = 0) = WebSocket.async[JsValue] { request =>
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

	def setView(wallId: Long) = AuthenticatedAction { implicit request =>
		val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
		val x = params.get("x").getOrElse(Seq("0.0"))(0).toDouble
		val y = params.get("y").getOrElse(Seq("0.0"))(0).toDouble
		val zoom = params.get("zoom").getOrElse(Seq("1.0"))(0).toDouble

		models.WallPreference.setView(currentUserId, wallId, x, y, zoom)
		Ok(Json.toJson("OK"))
	}

	def rename(wallId: Long, name: String) = AuthenticatedAction { implicit request =>
		models.Wall.rename(wallId, name)
		Ok(Json.toJson("OK"))
	}

	def moveTo(wallId: Long, folderId: Long) = AuthenticatedAction { implicit request =>
		models.Wall.moveTo(wallId, folderId)
		Ok(Json.toJson("OK"))
	}

  /**  uploaded files **/
  def uploadFile(wallId: Long) = AuthenticatedAction(parse.multipartFormData) { request =>

    var fileList:Seq[JsObject] = List()

    request.body.files.map { picture =>
      import java.io.File
      val filename = picture.filename
      val contentType = picture.contentType
      val newFile = new File("public/files/"+ picture.filename)
      picture.ref.moveTo(newFile, true)

      fileList = fileList :+ JsObject(Seq(
        "name" -> JsString(filename),
        "size" -> JsNumber(newFile.length),
        "url" -> JsString("/assets/files/" + picture.filename),
        "delete_url" -> JsString("/wall/file/"+wallId),
        "delete_type" -> JsString("delete")
      ))
    }
    Ok(JsArray(fileList))
  }

  def infoFile(wallId: Long) = Action {
    // TODO: implement
    Ok("")
  }

  def replaceFile(wallId: Long) = AuthenticatedAction { request =>
    // TODO: implement
    Ok("")
  }

  def deleteFile(wallId: Long) = AuthenticatedAction { request =>
    // TODO: implement
    Ok("")
  }
}
