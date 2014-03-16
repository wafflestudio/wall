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
import models.Wall
import models.ChatRoom
import models.WallLog
import models.Sheet
import models.SheetLink
import models.WallPreference
import models.ResourceTree
import scala.util.Success
import scala.util.Failure
import models.RootFolder
import org.apache.commons.codec.digest.DigestUtils
import indexing._
import models.ActiveRecord._
import play.api.libs.Comet
import scala.concurrent.Future
import org.apache.tika.Tika

object WallController extends Controller with SecureSocial {

	def index = SecuredAction { implicit request =>
		Ok(views.html.wall.index())
	}

	def getUserWalls = SecuredAction { implicit request =>
		val walls = User.listNonSharedWalls(currentUserId).map(_.frozen)
		Ok(Json.toJson(walls.map { wall =>
			(wall.id, wall.name)
		}.toMap))
	}

	// FIXME: properly show group and wall as folder structure
	def getSharedWalls = SecuredAction { implicit request =>
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

	def tree = SecuredAction { implicit request =>
		val tree = Wall.tree(currentUserId)
		Ok(resourceTree2Json(tree))
	}

	def view(wallId: String) = SecuredAction { implicit request =>
		val wall = transactional { Wall.findById(wallId).map(_.frozen) }

		wall match {
			case Some(w) =>
				if (Wall.hasReadPermission(wallId, currentUserId)) {
					val chatRoomId = ChatRoom.findOrCreateForWall(wallId).frozen.id
					val (timestamp, sheets, sheetlinks) =
						(WallLog.timestamp(wallId), Sheet.findAllByWallId(wallId).map(_.frozen), SheetLink.findAllByWallId(wallId).map(_.frozen))

					val pref = WallPreference.findOrCreate(currentUserId, wallId).frozen
					Ok(views.html.wall.view(wallId, w.name, pref, sheets, sheetlinks, timestamp, chatRoomId))
				} else {
					Forbidden("Request wall with id " + wallId + " not accessible")
				}
			case None =>
				Forbidden("Request wall with id " + wallId + " not accessible")
		}
	}

	def stage(wallId: String) = SecuredAction { implicit request =>
		val wall = transactional { Wall.findById(wallId).map(_.frozen) }

		wall match {
			case Some(w) =>
				if (Wall.hasEditPermission(wallId, currentUserId)) {
					val chatRoomId = ChatRoom.findOrCreateForWall(wallId).frozen.id
					val (timestamp, sheets, sheetlinks) =
						(WallLog.timestamp(wallId), Sheet.findAllByWallId(wallId).map(_.frozen), SheetLink.findAllByWallId(wallId).map(_.frozen))

					val pref = WallPreference.findOrCreate(currentUserId, wallId).frozen
					Ok(views.html.wall.stage(wallId, w.name, pref, sheets, sheetlinks, timestamp, chatRoomId))
				} else {
					Forbidden("Request wall with id " + wallId + " not accessible")
				}
			case None =>
				Forbidden("Request wall with id " + wallId + " not accessible")
		}
	}

	def create = SecuredAction { implicit request =>
		Logger.info("create Wall:" + jsonParams.toString)
		val title = (jsonParams \ "title").asOpt[String].getOrElse("unnamed")

		val wallId = Wall.create(currentUserId, title).frozen.id
		Redirect(routes.WallController.stage(wallId))
	}

	def sync(wallId: String) = WebSocket.async[JsValue] { implicit request =>
		val uuid = queryParam("uuid")
		val timestamp = queryParam("timestamp").toLong

		currentUser match {
			case Some(user) =>
				WallSystem.establish(wallId, user.identityId.userId, uuid, timestamp)
			case _ =>
				val consumer = Done[JsValue, Unit]((), Input.EOF)
				val producer = Enumerator[JsValue](Json.obj("error" -> "Unauthorized")).andThen(Enumerator.enumInput(Input.EOF))
				Future.successful(consumer, producer)
		}
	}

	// http send by client
	def speak(wallId: String) = SecuredAction { implicit request =>
		val uuid = queryParam("uuid")
		Logger.info(s"speak1: ${bodyText}")
		val action = Json.parse(Json.parse(bodyText).as[String])
		Logger.info(s"speak2: $action")
		WallSystem.submitActions(wallId, request.user.identityId.userId, uuid, 0, action)
		Ok("")
	}

	// http receive
	def listen(wallId: String) = UserAwareAction.async { implicit request =>
		import play.api.templates.Html
		import play.api.libs.concurrent.Execution.Implicits._
		val uuid = queryParam("uuid")
		val timestamp = queryParam("timestamp").toLong

		request.user match {
			case Some(user) =>
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
			case _ =>
				Future(Forbidden("Request wall with id " + wallId + " not accessible"))
		}
	}

	def delete(id: String) = SecuredAction { implicit request =>
		val verified = formParam("verified").toBoolean
		if (verified)
			Wall.deleteByUserId(currentUserId, id)
		Ok(Json.toJson("OK"))
	}

	def setView(wallId: String) = SecuredAction { implicit request =>
		val x = formParam("x").toDouble
		val y = formParam("y").toDouble
		val zoom = formParam("zoom").toDouble

		WallPreference.setView(currentUserId, wallId, x, y, zoom)
		Ok(Json.toJson("OK"))
	}

	def search(wallId: String, keyword: String) = SecuredAction { implicit request =>
		val results = SheetIndexManager.search(wallId, keyword)
		Ok(Json.toJson(results))
	}

	def rename(wallId: String, name: String) = SecuredAction { implicit request =>
		Wall.rename(wallId, name)
		Ok(Json.toJson("OK"))
	}

	def moveTo(wallId: String, folderId: String) = SecuredAction { implicit request =>
		Wall.moveTo(wallId, folderId)
		Ok(Json.toJson("OK"))
	}

	/**  uploaded files **/
	def uploadFile(wallId: String) = UserAwareAction(parse.multipartFormData) { implicit request =>
		request.user match {
			case Some(currentUser) => {
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
			case _ => Unauthorized
		}
	}

	def infoFile(wallId: String) = SecuredAction { implicit request =>
		NotImplemented
	}

	def replaceFile(wallId: String) = SecuredAction { implicit request =>
		NotImplemented
	}

	def deleteFile(wallId: String) = SecuredAction { implicit request =>
		NotImplemented
	}
}
