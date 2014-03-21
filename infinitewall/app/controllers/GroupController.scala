package controllers

import models.ActiveRecord.Alias
import models.Group
import play.api.Logger
import play.api.libs.json.Json

object GroupController extends Controller with SecureSocial {

	def index = securedAction { implicit request =>
		val groups = models.User.listGroups(currentUserId).map(_.frozen)
		Ok(views.html.group.index(groups))
	}

	def show(id: String) = securedAction { implicit request =>
		Ok(views.html.group.show(id))
	}

	def create = securedAction { implicit request =>
		val name = formParam("name")
		val groupId = Group.createForUser(name, currentUserId).frozen.id

		Group.addUser(groupId, currentUserId)
		Redirect(routes.GroupController.show(groupId))
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
			val userEmail = formParam("email")

			val user = models.User.findByEmail(userEmail).map(_.frozen)
			user.map { u =>
				Logger.info(u.email)
				Group.addUser(groupId, u.id)
			}
			Redirect(routes.GroupController.show(groupId))
		} else
			Forbidden("Invalid Request")
	}

	def createWall(groupId: String) = securedAction { implicit request =>
		val title = jsonParam("title")
		val wallId = models.Wall.create(currentUserId, title).frozen.id
		val wall = models.Wall.findById(wallId).map(_.frozen)

		wall.map { w =>
			Logger.info("hi")
			Logger.info(w.name)
			Group.addWall(groupId, w.id)
		}
		Redirect(routes.WallController.stage(wallId))
	}

	def addWallPost(groupId: String) = SecuredAction { implicit request =>
		val wallId = formParam("wall_id")

		if (models.Wall.hasEditPermission(wallId, request.user.identityId.userId)) {
			val wall = models.Wall.findById(wallId).map(_.frozen)
			wall.map { w =>
				Group.addWall(groupId, w.id)
			}
			Redirect(routes.GroupController.show(groupId))
		} else {
			Forbidden("Invalid Request")
		}
	}

	def getWalls(groupId: String) = securedAction { implicit request =>
		val walls = models.User.listNonSharedWalls(currentUserId).map(_.frozen).map { wall =>
			(wall.id, wall.name)
		}.toMap

		Ok(Json.toJson(walls))
	}

	def getSharedWalls(groupId: String) = securedAction { implicit request =>
		if (Group.isValid(groupId, currentUserId)) {
			val walls = Group.listWalls(groupId).map(_.frozen).map { wall =>
				(wall.id, wall.name)
			}.toMap

			Ok(Json.toJson(walls))
		} else
			Forbidden(Json.toJson("Unauthorized access"))
	}

	def addWall(groupId: String, wallId: String) = securedAction { implicit request =>
		val wall = models.Wall.findById(wallId).map(_.frozen)
		if (models.Wall.hasEditPermission(wallId, currentUserId)) {
			wall.map { w =>
				Group.addWall(groupId, w.id)
			}

			Redirect(routes.GroupController.show(groupId))
		} else {
			Forbidden("Invalid Request")
		}
	}

	def removeUser(groupId: String, userId: String) = securedAction { implicit request =>
		Group.removeUser(groupId, userId)
		Redirect(routes.GroupController.show(groupId))
	}

	def removeWall(groupId: String, wallId: String) = securedAction { implicit request =>
		Group.removeWall(groupId, wallId)
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
}
