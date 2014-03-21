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
import wall.WallSystem

object WallController extends Controller with SecureSocial {

	def index = securedAction { implicit request =>
		Ok(views.html.wall.index())
	}

	def getUserWalls = securedAction { implicit request =>
		val walls = User.listNonSharedWalls(currentUserId).map(_.frozen)
		Ok(Json.toJson(walls.map { wall =>
			(wall.id, wall.name)
		}.toMap))
	}

	// FIXME: properly show group and wall as folder structure
	def getSharedWalls = securedAction { implicit request =>
		val walls = models.User.listSharedWalls(currentUserId).map(_.frozen)
		Ok(Json.toJson(walls.map { wall =>
			(wall.id, wall.name)
		}.toMap))
	}

	implicit def resourceTree2Json(implicit tree: ResourceTree): JsValue = {
		tree.node match {
			case root: models.RootFolder =>
				JsArray(tree.children.map(resourceTree2Json(_)))
			case folder: models.Folder.Frozen =>
				Json.obj("type" -> "folder", "id" -> folder.id, "name" -> folder.name,
					"children" -> Json.arr(tree.children.map(resourceTree2Json(_))))
			case wall: Wall.Frozen =>
				Json.obj("type" -> "wall", "id" -> wall.id, "name" -> wall.name)
		}
	}

	def tree = securedAction { implicit request =>
		val tree = Wall.tree(currentUserId)
		Ok(resourceTree2Json(tree))
	}

	def view(wallId: String) = securedAction { implicit request =>
		val wall = transactional { Wall.findById(wallId).map(_.frozen) }.get

		if (Wall.hasReadPermission(wallId, currentUserId)) {
			val chatRoomId = ChatRoom.findOrCreateForWall(wallId).frozen.id
			val (timestamp, sheets, sheetlinks) =
				(WallLog.timestamp(wallId), Sheet.findAllByWallId(wallId).map(_.frozen), SheetLink.findAllByWallId(wallId).map(_.frozen))

			val pref = WallPreference.findOrCreate(currentUserId, wallId).frozen
			Ok(views.html.wall.view(wallId, wall.name, pref, sheets, sheetlinks, timestamp, chatRoomId))
		} else
			Forbidden("Request wall with id " + wallId + " not accessible")

	}

	def stage(wallId: String) = securedAction { implicit request =>
		val wall = transactional { Wall.findById(wallId).map(_.frozen) }.get

		if (Wall.hasEditPermission(wallId, currentUserId)) {
			val chatRoomId = ChatRoom.findOrCreateForWall(wallId).frozen.id
			val (timestamp, sheets, sheetlinks) =
				(WallLog.timestamp(wallId), Sheet.findAllByWallId(wallId).map(_.frozen), SheetLink.findAllByWallId(wallId).map(_.frozen))

			val pref = WallPreference.findOrCreate(currentUserId, wallId).frozen
			Ok(views.html.wall.stage(wallId, wall.name, pref, sheets, sheetlinks, timestamp, chatRoomId))
		} else
			Forbidden("Request wall with id " + wallId + " not accessible")
	}

	def create = securedAction { implicit request =>
		Logger.info("create Wall:" + jsonParams.toString)
		val title = (jsonParams \ "title").asOpt[String].getOrElse("unnamed")

		val wallId = Wall.create(currentUserId, title).frozen.id
		Redirect(routes.WallController.stage(wallId))
	}

	def sync(wallId: String) = securedWebsocket { implicit request =>
		val uuid = queryParam("uuid")
		val timestamp = queryParam("timestamp").toLong
		val user = currentUser.get

		WallSystem.establish(wallId, user.identityId.userId, uuid, timestamp)

	}

	// http send by client
	def speak(wallId: String) = securedAction { implicit request =>
		val uuid = queryParam("uuid")
		Logger.info(s"speak1: ${bodyText}")
		val action = Json.parse(Json.parse(bodyText).as[String])
		Logger.info(s"speak2: $action")
		WallSystem.submitActions(wallId, request.user.identityId.userId, uuid, 0, action)
		Ok("")
	}

	// http receive
	def listen(wallId: String) = SecuredAction.async { implicit request =>
		import play.api.templates.Html
		import play.api.libs.concurrent.Execution.Implicits._
		val uuid = queryParam("uuid")
		val timestamp = queryParam("timestamp").toLong
		val user = request.user

		WallSystem.establish(wallId, user.identityId.userId, uuid, timestamp).map { channels =>
			// force disconnect after 3 seconds
			val timeoutEnumerator: Enumerator[JsValue] = Enumerator.generateM[JsValue] {
				Promise.timeout(Some(JsNumber(0)), 3.seconds)
			}.mapInput {
				case _ => Input.EOF
			}
			timeoutEnumerator.apply(channels._1)
			// convert to comet stream
			val stream = channels._2 &> Comet(callback = "triggerOnReceive")
			Ok.chunked(stream)
		}

	}

	def delete(id: String) = securedAction { implicit request =>
		val verified = formParam("verified").toBoolean
		if (verified)
			Wall.deleteByUserId(currentUserId, id)
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
