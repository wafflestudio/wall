package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.Play.current
import play.api.db.DB

object Folder extends Controller with Auth {
	def create(name:String, parentId:Long) = AuthenticatedAction { implicit request => 
		models.Folder.create(name, currentUserId, Some(parentId))
		Ok("")
	}
	
	def rename(id:Long, name:String) = AuthenticatedAction { implicit request => 
		models.Folder.rename(id, name)
		Ok("")
	}
	
	def delete(id:Long) = AuthenticatedAction { implicit request => 
		models.Folder.delete(id)
		Ok("")
	}
	
	def moveTo(id:Long, parentId:Long) = AuthenticatedAction { implicit request => 
		models.Folder.moveTo(id, parentId)
		Ok("")
	}
}