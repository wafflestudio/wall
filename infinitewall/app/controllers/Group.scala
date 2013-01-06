package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.Play.current
import play.api.db.DB

object Group extends Controller with Auth with Login {
	def index = AuthenticatedAction { implicit request =>
		val groups = models.User.listGroups(currentUserId)
		Ok(views.html.group.index(groups))
	}
	
	def show(id: Long) = AuthenticatedAction { implicit request =>
		val users = models.Group.listUsers(id)
		val walls = models.Group.listWalls(id)
		Ok(views.html.group.show(users, walls, id))
	}
	
	def create = AuthenticatedAction { implicit request =>
		val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
		val name = params.get("name").getOrElse(Seq("unnamed"))
		val groupId = models.Group.create(name(0), currentUserId)
		Redirect(routes.Group.show(groupId))
	}
	
	def addUser(groupId: Long) = AuthenticatedAction { implicit request =>
		val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
		val userEmail = params.get("email").getOrElse(Seq("unnamed"))
		Logger.info(userEmail(0))
		val user = models.User.findByEmail(userEmail(0))
		user.map { u =>
			Logger.info("hi")
			Logger.info(u.email)
			models.Group.addUser(groupId, u.id.get)
		}
		Redirect(routes.Group.show(groupId))
	}
	
	def createWall(groupId: Long) = AuthenticatedAction { implicit request =>
		val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
		val title = params.get("title").getOrElse(Seq("unnamed"))
		val wallId = models.Wall.create(currentUserId, title(0))
		val wall = models.Wall.findById(wallId)
		wall.map { w =>
			Logger.info("hi")
			Logger.info(w.name)
			models.Group.addWall(groupId, w.id.get)
			Redirect(routes.Wall.stage(wallId))
		}.getOrElse(BadRequest)
		
	}
	
	def addWall(groupId: Long) = AuthenticatedAction { implicit request =>
		val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
		val wallId = params.get("wall_id").getOrElse(Seq("-1"))
		val wall = models.Wall.findById(wallId(0).toLong)
		wall.map { w =>
			Logger.info("hi")
			Logger.info(w.name)
			models.Group.addWall(groupId, w.id.get)
		}
		Redirect(routes.Group.show(groupId))
	}
	
	def removeUser(groupId: Long, userId: Long) = AuthenticatedAction { implicit request =>
		models.Group.removeUser(groupId, userId)
		Redirect(routes.Group.show(groupId))
	}
	
	def removeWall(groupId: Long, wallId: Long) = AuthenticatedAction { implicit request =>
		models.Group.removeWall(groupId, wallId)
		Redirect(routes.Group.show(groupId))
	}
	
	def rename(id: Long, name: String) = AuthenticatedAction { implicit request =>
		models.Group.rename(id, name)
		Ok("")
	}
	def delete(id: Long) = AuthenticatedAction { implicit request =>
		models.Group.delete(id)
		Ok("")
	}
}
