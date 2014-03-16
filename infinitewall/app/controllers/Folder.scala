package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.Play.current
import play.api.db.DB

object Folder extends Controller with SecureSocial {
	def create(parentId: String = "") = SecuredAction { implicit request =>
		val name = jsonParam("name")

		if (parentId == "")
			models.Folder.create(name, currentUserId, None)
		else
			models.Folder.create(name, currentUserId, Some(parentId))
		Ok(Json.toJson("OK"))
	}

	def rename(id: String) = SecuredAction { implicit request =>
		val name = jsonParam("name")
		models.Folder.rename(id, name)
		Ok(Json.toJson("OK"))
	}

	def delete(id: String) = SecuredAction { implicit request =>
		models.Folder.delete(id)
		Ok(Json.toJson("OK"))
	}

	def move(id: String, parentId: String) = SecuredAction { implicit request =>
		models.Folder.moveTo(id, parentId)
		Ok(Json.toJson("OK"))
	}
}
