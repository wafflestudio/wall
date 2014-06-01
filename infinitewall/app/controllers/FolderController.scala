package controllers

import models.Folder
import play.api.libs.json.Json

object FolderController extends Controller with SecureSocial {

	def createAtRoot() = securedAction { implicit request =>
		val name = jsonParam("name")

		Folder.create(name, currentUserId, None)
		Ok(Json.toJson("OK"))
	}

	def create(parentId: String) = securedAction { implicit request =>
		val name = jsonParam("name")

		Folder.create(name, currentUserId, Some(parentId))
		Ok(Json.toJson("OK"))
	}

	def rename(id: String) = securedAction { implicit request =>
		val name = jsonParam("name")
		Folder.rename(id, name)
		Ok(Json.toJson("OK"))
	}

	def delete(id: String) = securedAction { implicit request =>
		Folder.delete(id)
		Ok(Json.toJson("OK"))
	}

	def moveTo(id: String, parentId: String) = securedAction { implicit request =>
		Folder.moveTo(id, parentId)
		Ok(Json.toJson("OK"))
	}

	def moveToRoot(id: String) = securedAction { implicit request =>
		Folder.moveToRoot(id)
		Ok(Json.toJson("OK"))
	}

}
