package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.Play.current
import play.api.db.DB

object Group extends Controller with Auth with Login {
  
  def index = AuthenticatedAction { implicit request =>
    val groups = models.User.listGroups(currentUserId).map(_.frozen)
    Ok(views.html.group.index(groups))
  }
  
  def show(id: String) = AuthenticatedAction { implicit request =>
    val users = models.Group.listUsers(id).map(_.frozen)
    val walls = models.User.listSharedWalls(currentUserId).map(_.frozen)
    val nonSharedWalls = models.User.listNonSharedWalls(currentUserId).map(_.frozen)
    Ok(views.html.group.show(users, walls, nonSharedWalls, id))
  }
  
  def create = AuthenticatedAction { implicit request =>
    val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
    val name = params.get("name").getOrElse(Seq("unnamed"))
    val groupId = models.Group.createForUser(name(0), currentUserId).frozen.id
    models.Group.addUser(groupId, currentUserId)
    Redirect(routes.Group.show(groupId))
  }

  def addUser(groupId: String) = AuthenticatedAction { implicit request =>
    if (models.Group.isValid(groupId, currentUserId)) {
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

  def createWall(groupId: String) = AuthenticatedAction { implicit request =>
    val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
    val title = params.get("title").getOrElse(Seq("unnamed"))
    val wallId = models.Wall.create(currentUserId, title(0)).frozen.id
    val wall = models.Wall.findById(wallId).map(_.frozen)
    wall.map { w =>
      Logger.info("hi")
      Logger.info(w.name)
      models.Group.addWall(groupId, w.id)
    }
    Redirect(routes.Wall.stage(wallId))
  }
  
  def addWallPost(groupId: String) = AuthenticatedAction { implicit request =>
    val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
    val wallId = params.get("wall_id").getOrElse(Seq(""))
    if (models.Wall.isValid(wallId(0), currentUserId)) {
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
  
  def addWall(groupId: String, wallId: String) = AuthenticatedAction { implicit request =>
    val wall = models.Wall.findById(wallId).map(_.frozen)
    if (models.Wall.isValid(wallId, currentUserId)) {
      wall.map { w =>
        models.Group.addWall(groupId, w.id)
      }
      Redirect(routes.Group.show(groupId))
    }
    else {
      Forbidden("Invalid Request")
    }
  }
  
  def removeUser(groupId: String, userId: String) = AuthenticatedAction { implicit request =>
    models.Group.removeUser(groupId, userId)
    Redirect(routes.Group.show(groupId))
  }
  
  def removeWall(groupId: String, wallId: String) = AuthenticatedAction { implicit request =>
    models.Group.removeWall(groupId, wallId)
    Redirect(routes.Group.show(groupId))
  }
  
  def rename(id: String, name: String) = AuthenticatedAction { implicit request =>
    models.Group.rename(id, name)
    Ok("")
  }
  def delete(id: String) = AuthenticatedAction { implicit request =>
    models.Group.delete(id)
    Ok("")
  }
}
