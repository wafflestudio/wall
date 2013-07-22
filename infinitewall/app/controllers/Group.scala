package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.Play.current
import play.api.db.DB

object Group extends Controller with securesocial.core.SecureSocial {
  
  def index = SecuredAction { implicit request =>
    val groups = models.User.listGroups(request.user.id.id).map(_.frozen)
    Ok(views.html.group.index(groups))
  }
  
  def show(id: String) = SecuredAction { implicit request =>
    val users = models.Group.listUsers(id).map(_.frozen)
    val walls = models.User.listSharedWalls(request.user.id.id).map(_.frozen)
    val nonSharedWalls = models.User.listNonSharedWalls(request.user.id.id).map(_.frozen)
    Ok(views.html.group.show(users, walls, nonSharedWalls, id))
  }
  
  def create = SecuredAction { implicit request =>
    val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
    val name = params.get("name").getOrElse(Seq("unnamed"))
    val groupId = models.Group.createForUser(name(0), request.user.id.id).frozen.id
    models.Group.addUser(groupId, request.user.id.id)
    Redirect(routes.Group.show(groupId))
  }

  def addUser(groupId: String) = SecuredAction { implicit request =>
    if (models.Group.isValid(groupId, request.user.id.id)) {
      val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
      val userEmail = params.get("email").get(0)
      Logger.info(userEmail)
      val user = models.User.findByEmail(userEmail).map(_.frozen)
      user.map { u =>
        Logger.info(u.email)
        models.Group.addUser(groupId, u.id)
      }
      Redirect(routes.Group.show(groupId))
    }
    else {
      Forbidden("Invalid Request")
    }
  }

  def createWall(groupId: String) = SecuredAction { implicit request =>
    val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
    val title = params.get("title").getOrElse(Seq("unnamed"))
    val wallId = models.Wall.create(request.user.id.id, title(0)).frozen.id
    val wall = models.Wall.findById(wallId).map(_.frozen)
    wall.map { w =>
      Logger.info("hi")
      Logger.info(w.name)
      models.Group.addWall(groupId, w.id)
    }
    Redirect(routes.Wall.stage(wallId))
  }
  
  def addWallPost(groupId: String) = SecuredAction { implicit request =>
    val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
    val wallId = params.get("wall_id").getOrElse(Seq(""))
    if (models.Wall.isValid(wallId(0), request.user.id.id)) {
      val wall = models.Wall.findById(wallId(0)).map(_.frozen)
      wall.map { w =>
        models.Group.addWall(groupId, w.id)
      }
      Redirect(routes.Group.show(groupId))
    }
    else {
      Forbidden("Invalid Request")
    }
  }
  
  def addWall(groupId: String, wallId: String) = SecuredAction { implicit request =>
    val wall = models.Wall.findById(wallId).map(_.frozen)
    if (models.Wall.isValid(wallId, request.user.id.id)) {
      wall.map { w =>
        models.Group.addWall(groupId, w.id)
      }
      Redirect(routes.Group.show(groupId))
    }
    else {
      Forbidden("Invalid Request")
    }
  }
  
  def removeUser(groupId: String, userId: String) = SecuredAction { implicit request =>
    models.Group.removeUser(groupId, userId)
    Redirect(routes.Group.show(groupId))
  }
  
  def removeWall(groupId: String, wallId: String) = SecuredAction { implicit request =>
    models.Group.removeWall(groupId, wallId)
    Redirect(routes.Group.show(groupId))
  }
  
  def rename(id: String, name: String) = SecuredAction { implicit request =>
    models.Group.rename(id, name)
    Ok("")
  }
  def delete(id: String) = SecuredAction { implicit request =>
    models.Group.delete(id)
    Ok("")
  }
}
