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
import scala.util.Success
import scala.util.Failure
import models.RootFolder
import org.apache.commons.codec.digest.DigestUtils
import indexing._
import models.ActiveRecord._
import play.api.libs.Comet
import scala.actors.Future


object Wall extends Controller with Auth with Login {

  def index = AuthenticatedAction { implicit request =>
    val sharedWalls = models.User.listSharedWalls(currentUserId).map(_.frozen)
    val nonSharedWalls = models.User.listNonSharedWalls(currentUserId).map(_.frozen)
    //val walls = models.User.listNonSharedWalls(currentUserId)
    Ok(views.html.wall.index(nonSharedWalls, sharedWalls))
  }

  implicit def resourceTree2Json(implicit tree: ResourceTree): JsValue = {
    tree.node match {
      case root: models.RootFolder =>
        JsArray(tree.children.map(resourceTree2Json(_)))
      case folder: models.Folder.Frozen =>
        Json.obj("type" -> "folder", "id" -> folder.id, "name" -> folder.name,
          "children" -> Json.arr(tree.children.map(resourceTree2Json(_))))
      case wall: models.Wall.Frozen =>
        Json.obj("type" -> "wall", "id" -> wall.id, "name" -> wall.name)
    }
  }

  def tree = AuthenticatedAction { implicit request =>
    val tree = models.Wall.tree(currentUserId)
    Ok(resourceTree2Json(tree))
  }

  def stage(wallId: String) = AuthenticatedAction { implicit request =>
    val wall = transactional { models.Wall.findById(wallId).map(_.frozen) }

    wall match {
      case Some(w) =>
        if (models.Wall.isValid(wallId, currentUserId)) {
          val chatRoomId = ChatRoom.findOrCreateForWall(wallId).frozen.id
          val (timestamp, sheets, sheetlinks) = DB.withConnection { implicit c =>
            (WallLog.timestamp(wallId), Sheet.findAllByWallId(wallId).map(_.frozen), SheetLink.findAllByWallId(wallId).map(_.frozen))
          }
          val pref = WallPreference.findOrCreate(currentUserId, wallId).frozen
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
    val wallId = models.Wall.create(currentUserId, title(0)).frozen.id
    Redirect(routes.Wall.stage(wallId))
  }

  def sync(wallId: String) = WebSocket.async[JsValue] { request =>
    val params = request.queryString
    val timestamp = params.get("timestamp").getOrElse(Seq("999"))(0).toLong
    
    request.session.get("current_user_id") match {
      case Some(userId) =>
        WallSystem.establish(wallId, userId, timestamp)
      case None =>
        val consumer = Done[JsValue, Unit]((), Input.EOF)
        val producer = Enumerator[JsValue](Json.obj("error" -> "Unauthorized")).andThen(Enumerator.enumInput(Input.EOF))
        Promise.pure(consumer, producer)
    }
  }

  def syncHttp(wallId: String, timestamp:Long) = Action { request =>
    import play.api.templates.Html
    import play.api.libs.concurrent.Execution.Implicits._
    
//    val params = request.queryString
    //val timestamp = params.get("timestamp").getOrElse(Seq("999"))(0).toLong
//    val toCometMessage = Enumeratee.map[JsValue] { data => 
//      Html("""<script>console.log('""" + data + """')</script>""")
//    }
    
    val timeoutFuture = play.api.libs.concurrent.Promise.timeout("Oops", 2.seconds)
    
    request.session.get("current_user_id") match {
      case Some(userId) =>
        Async {
          WallSystem.establish(wallId, userId, timestamp).map(
              channels => Ok.stream(channels._2 &> Comet(callback = "parent.WallSocket.onCometReceive") ))
        }
      case None =>
        Forbidden("Request wall with id " + wallId + " not accessible")
    }
  }

  def delete(id: String) = AuthenticatedAction { implicit request =>
    models.Wall.deleteByUserId(currentUserId, id)
    Ok(Json.toJson("OK"))
  }

  def setView(wallId: String) = AuthenticatedAction { implicit request =>
    val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
    val x = params.get("x").getOrElse(Seq("0.0"))(0).toDouble
    val y = params.get("y").getOrElse(Seq("0.0"))(0).toDouble
    val zoom = params.get("zoom").getOrElse(Seq("1.0"))(0).toDouble

    models.WallPreference.setView(currentUserId, wallId, x, y, zoom)
    Ok(Json.toJson("OK"))
  }

  def search(wallId: String, keyword: String) = AuthenticatedAction { implicit request =>
    val results = SheetIndexManager.search(wallId, keyword)
    Ok(Json.toJson(results))
  }


  def rename(wallId: String, name: String) = AuthenticatedAction { implicit request =>
    models.Wall.rename(wallId, name)
    Ok(Json.toJson("OK"))
  }

  def moveTo(wallId: String, folderId: String) = AuthenticatedAction { implicit request =>
    models.Wall.moveTo(wallId, folderId)
    Ok(Json.toJson("OK"))
  }

  /**  uploaded files **/
  def uploadFile(wallId: String) = AuthenticatedAction(parse.multipartFormData) { request =>
    // FIXME: use more functional approach using val and foldleft
    var fileList: Seq[JsObject] =
      request.body.files.foldLeft[Seq[JsObject]](List()) { (fileList, picture) =>
        // FIXME: make use of content type
        val contentType = picture.contentType

        utils.FileSystem.moveTempFile(picture.ref, "public/files", picture.filename) match {
          case Success(pair) =>
            val (filename, file) = pair
            fileList :+ Json.obj(
              "name" -> filename,
              "size" -> file.length,
              "url" -> ("/upload/" + filename),
              "delete_url" -> ("/wall/file/" + wallId),
              "delete_type" -> "delete"
            )
          case Failure(_) =>
            // TODO: add message? that a file upload failed
            fileList
        }
      }
    Ok(JsArray(fileList))
  }

  def infoFile(wallId: String) = Action {
    // TODO: implement
    Ok("")
  }

  def replaceFile(wallId: String) = AuthenticatedAction { request =>
    // TODO: implement
    Ok("")
  }

  def deleteFile(wallId: String) = AuthenticatedAction { request =>
    // TODO: implement
    Ok("")
  }
}
