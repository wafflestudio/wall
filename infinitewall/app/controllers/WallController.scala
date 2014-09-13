package controllers

import scala.concurrent.Future
import scala.concurrent.duration.DurationInt
import scala.math.BigDecimal.int2bigDecimal
import scala.util.{ Failure, Success }

import org.apache.tika.Tika

import indexing.SheetIndexManager
import models.{ ChatRoom, ResourceTree, Sheet, SheetLink, User, Wall, WallLog, WallPreference }
import models.ActiveRecord.transactional
import play.api.Logger
import play.api.libs.Comet
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.concurrent.Promise
import play.api.libs.iteratee.{ Done, Enumerator, Input }
import play.api.libs.json.{ JsArray, JsNumber, JsObject, JsValue, Json }
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import play.api.mvc.WebSocket
import services.wall.WallService

object WallController extends Controller with SecureSocial {

	def index = securedAction { implicit request =>
		Ok(views.html.wall.index())
	}

	def getUserWalls = securedAction { implicit request =>
		val walls = User.getNonSharedWalls(currentUserId).map(_.frozen)
		Ok(Json.toJson(walls.map { wall =>
			(wall.id, wall.name)
		}.toMap))
	}

	// FIXME: properly show group and wall as folder structure
	def getWallsInGroups = securedAction { implicit request =>
		val wallsWithGroups = models.User.getWallsInGroups(currentUserId).map {
			case (wall, group) =>
				(wall.frozen, group.frozen)
		}

		var map = scala.collection.mutable.Map[models.Group.Frozen, List[models.Wall.Frozen]]()
		wallsWithGroups.map {
			case (wall, group) =>
				map(group) = map.getOrElse(group, List()) :+ wall
		}

		Ok(JsObject(map.map {
			case (group, walls) =>
				(group.id,
					Json.obj("name" -> group.name,
						"walls" -> walls.map(wall =>
							Json.obj("id" -> wall.id, "name" -> wall.name, "isMine" -> (wall.userId == currentUserId)))))
		}.toSeq))
	}

	def getSharedWalls = securedAction { implicit request =>
		val walls = models.User.getSharedWalls(currentUserId).map(_.frozen)
		Ok(JsObject(walls.map { wall =>
			(wall.id, Json.obj("name" -> wall.name, "isMine" -> (wall.userId == currentUserId)))
		}.toSeq))
	}

	private def resourceTree2Json(tree: ResourceTree): JsValue = {
		tree.node match {
			case root: models.RootFolder =>
				JsArray(tree.children.map(resourceTree2Json(_)))
			case folder: models.Folder.Frozen =>
				Json.obj("type" -> "folder", "id" -> folder.id, "name" -> folder.name,
					"label" -> (if (folder.name != "") folder.name else "<unnamed>"),
					"children" -> (if (tree.children.isEmpty) Json.arr() else tree.children.map(resourceTree2Json(_))))
			case wall: Wall.Frozen =>
				Json.obj("type" -> "wall", "id" -> wall.id, "name" -> wall.name, "label" -> (if (wall.name != "") wall.name else "<unnamed>"))
		}
	}

	def tree = securedAction { implicit request =>
		val tree = Wall.tree(currentUserId)
		Ok(Json.arr(Json.obj("type" -> "folder", "name" -> "root", "label" -> "My Walls", "children" -> resourceTree2Json(tree))))
	}

	def view(wallId: String) = securedAction { implicit request =>
		val wall = transactional { Wall.find(wallId).map(_.frozen) }.get

		if (Wall.hasReadPermission(wallId, currentUserId)) {
			val chatRoomId = ChatRoom.findOrCreateForWall(wallId).frozen.id
			val (timestamp, sheets, sheetlinks) =
				(WallLog.timestamp(wallId), Sheet.findAllByWall(wallId).map(_.frozen), SheetLink.findAllByWall(wallId).map(_.frozen))

			val pref = WallPreference.findOrCreate(currentUserId, wallId).frozen
			Ok(views.html.wall.view(wallId, wall.name, pref, sheets, sheetlinks, timestamp, chatRoomId))
		} else
			Forbidden("Request wall with id " + wallId + " not accessible")

	}

	def stage(wallId: String) = securedAction { implicit request =>
		val wall = Wall.find(wallId).map(_.frozen).get

		if (Wall.hasEditPermission(wallId, currentUserId)) {
			val chatRoomId = ChatRoom.findOrCreateForWall(wallId).frozen.id
			val (timestamp, sheets, sheetlinks) = transactional {
				(WallLog.timestamp(wallId), Sheet.findAllByWall(wallId).map(_.frozen), SheetLink.findAllByWall(wallId).map(_.frozen))
			}

			val pref = WallPreference.findOrCreate(currentUserId, wallId).frozen
			Ok(views.html.wall.stage(wallId, wall.name, pref, sheets, sheetlinks, timestamp, chatRoomId))
		} else
			Forbidden("Request wall with id " + wallId + " not accessible")
	}

	def create = securedAction { implicit request =>
		val title = jsonParam("title")

		val wallId = Wall.create(currentUserId, title).frozen.id
		Redirect(routes.WallController.stage(wallId))
	}
	/*
	// websocket IO stream of events
	def sync(wallId: String) = securedWebsocket { implicit request =>
		val uuid = queryParam("uuid")
		val timestamp = queryParam("timestamp").toLong
		val user = currentUser.get

		WallService.establish(wallId, user.identityId.userId, uuid, timestamp)
	}
	*/

	def delete(id: String) = securedAction { implicit request =>
		Wall.deleteForUser(currentUserId, id)
		Ok(Json.toJson("OK"))
	}

	def setView(wallId: String) = securedAction { implicit request =>
		val x = formParam("x").toDouble
		val y = formParam("y").toDouble
		val zoom = formParam("zoom").toDouble

		WallPreference.setView(currentUserId, wallId, x, y, zoom)
		Ok(Json.toJson("OK"))
	}

	def search(wallId: String, keyword: String) = securedAction { implicit request =>
		val results = SheetIndexManager.search(wallId, keyword)
		Ok(Json.toJson(results))
	}

	def rename(wallId: String, name: String) = securedAction { implicit request =>
		Wall.rename(wallId, name)
		Ok(Json.toJson("OK"))
	}

	def moveTo(wallId: String, folderId: String) = securedAction { implicit request =>
		Wall.moveTo(wallId, folderId)
		Ok(Json.toJson("OK"))
	}

	def moveToRoot(wallId: String) = securedAction { implicit request =>
		Wall.moveToRoot(wallId)
		Ok(Json.toJson("OK"))
	}

	/**  uploaded files **/
	def uploadFile(wallId: String) = securedAction(parse.multipartFormData) { implicit request =>
		val currentUser = request.user
		val fileList: Seq[JsObject] =
			request.body.files.flatMap { picture =>
				val tika = new Tika()
				val contentType: String = tika.detect(picture.ref.file)
				val imageContentTypePattern = "^image/(\\w)+".r
				contentType match {
					case imageContentTypePattern(c) =>
						utils.FileSystem.moveTempFile(picture.ref, "public/files", picture.filename) match {
							case Success((filename, file)) =>
								Some(Json.obj(
									"name" -> filename,
									"size" -> file.length,
									"url" -> ("/upload/" + filename),
									"delete_url" -> ("/wall/file/" + wallId),
									"delete_type" -> "delete"))
							case Failure(_) => None
						}
					case _ => Logger.info("Invalid mime-type: " + contentType); None
				}
			}
		Ok(JsArray(fileList))
	}

	def infoFile(wallId: String) = securedAction { implicit request =>
		NotImplemented
	}

	def replaceFile(wallId: String) = securedAction { implicit request =>
		NotImplemented
	}

	def deleteFile(wallId: String) = securedAction { implicit request =>
		NotImplemented
	}
}
