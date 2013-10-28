package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.Play.current
import play.api.db.DB

object Folder extends Controller with securesocial.core.SecureSocial {
	def create(name: String, parentId: String) = SecuredAction { implicit request =>
		models.Folder.create(name, request.user.identityId.userId, Some(parentId))
		Ok("")
	}

	def rename(id: String, name: String) = SecuredAction { implicit request =>
		models.Folder.rename(id, name)
		Ok("")
	}

	def delete(id: String) = SecuredAction { implicit request =>
		models.Folder.delete(id)
		Ok("")
	}

	def moveTo(id: String, parentId: String) = SecuredAction { implicit request =>
		models.Folder.moveTo(id, parentId)
		Ok("")
	}
}
