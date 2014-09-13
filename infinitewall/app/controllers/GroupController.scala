package controllers

import models.ActiveRecord.Alias
import models.{ User, Group, Wall }
import play.api.Logger
import play.api.libs.json.{ Json, JsObject }

object GroupController extends Controller with SecureSocial {

	def index = securedAction { implicit request =>
		val ownedGroups = User.listOwnedGroups(currentUserId).map(_.frozen)
		val includedGroups = User.listIncludedGroups(currentUserId).map(_.frozen)
		Ok(views.html.group.index(ownedGroups, includedGroups))
	}

	def show(id: String) = securedAction { implicit request =>
		val group = Group.findById(id).map(_.frozen).get
		Ok(views.html.group.show(id, group.name))
	}

	def create = securedAction { implicit request =>
		val name = formParam("name")
		val groupId = Group.createForUser(name, currentUserId).frozen.id

		Group.addUser(groupId, currentUserId)
		Redirect(routes.GroupController.show(groupId))
	}

	def rename(id: String, name: String) = securedAction { implicit request =>
		Group.rename(id, name)
		Ok("")
	}

	def delete(id: String) = securedAction { implicit request =>
		Group.delete(id)
		Ok("")
	}

	def getUsers(groupId: String) = securedAction { implicit request =>
		if (Group.isValid(groupId, currentUserId)) {
			val users = Group.listUsers(groupId).map(_.frozen).map { user =>
				(user.id, user.email)
			}.toMap
			Ok(Json.toJson(users))
		} else
			Forbidden("Invalid Request")
	}

	def addUser(groupId: String) = securedAction { implicit request =>
		if (Group.isValid(groupId, currentUserId)) {
			val userEmail = jsonParam("email")
			val user = User.findByEmail(userEmail).map(_.frozen)
			user.map { u =>
				Logger.info(u.email)
				Group.addUser(groupId, u.id)
			}
			Ok("")
		} else
			Forbidden("Invalid Request")
	}

	def removeUser(groupId: String, userId: String) = securedAction { implicit request =>
		Group.removeUser(groupId, userId)
		Redirect(routes.GroupController.show(groupId))
	}

	def getWalls(groupId: String) = securedAction { implicit request =>
		val walls = User.listNonSharedWalls(currentUserId).map(_.frozen).map { wall =>
			(wall.id, wall.name)
		}.toMap

		Ok(Json.toJson(walls))
	}

	def getSharedWalls(groupId: String) = securedAction { implicit request =>
		if (Group.isValid(groupId, currentUserId)) {
			val walls = Group.listWalls(groupId).map(_.frozen)
			Ok(JsObject(walls.map { wall =>
				(wall.id, Json.obj("name" -> wall.name, "isMine" -> (wall.userId == currentUserId)))
			}.toSeq))
		} else
			Forbidden(Json.toJson("Unauthorized access"))
	}

	def createWall(groupId: String) = securedAction { implicit request =>
		val title = jsonParam("title")
		val wallId = Wall.create(currentUserId, title).frozen.id
		val wall = Wall.findById(wallId).map(_.frozen)

		wall.map { w =>
			Logger.info("hi")
			Logger.info(w.name)
			Group.addWall(groupId, w.id)
		}
		Redirect(routes.WallController.stage(wallId))
	}

	def addWall(groupId: String, wallId: String) = securedAction { implicit request =>
		val wall = Wall.findById(wallId).map(_.frozen)
		if (Wall.hasEditPermission(wallId, currentUserId)) {
			wall.map { w =>
				Group.addWall(groupId, w.id)
			}

			Redirect(routes.GroupController.show(groupId))
		} else {
			Forbidden("Invalid Request")
		}
	}

	def removeWall(groupId: String, wallId: String) = securedAction { implicit request =>
		Group.removeWall(groupId, wallId)
		Redirect(routes.GroupController.show(groupId))
	}

}
