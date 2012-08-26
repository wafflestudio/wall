package models

import anorm._
import anorm.SqlParser._
import play.api.db.DB
import play.api.Play.current


trait TreeNode

case class RootFolder() extends TreeNode
case class Folder(id:Pk[Long], name:String, parentId:Option[Long], userId:Long) extends TreeNode

object Folder extends ActiveRecord[Folder] {
	val tableName = "Folder"
		
	val simple = {
		field[Pk[Long]]("id") ~
		field[String]("name") ~ 
		field[Option[Long]]("parent_id") ~ 
		field[Long]("user_id") map {
			case id ~ name ~ parentId ~ userId => Folder(id, name, parentId, userId)
		}
	}
	
	def create(name:String, userId:Long, parentId:Option[Long] = None) = {
		DB.withTransaction { implicit c =>
			val id = SQL("select next value for folder_seq").as(scalar[Long].single)
			
			parentId match { 
				case None => 
					SQL(""" 
						insert into """ + tableName + """ (id, name, user_id) values (
							{id},
							{name}, {userId}, {parentId}
						)
					""").on(
						'id -> id,
						'name -> name,
						'userId -> userId
					).executeUpdate()
					
				case Some(p_id) => 
					SQL(""" 
						insert into """ + tableName + """ (id, name, user_id, parent_id) values (
							{id},
							{name}, {userId}, {parentId}
						)
					""").on(
						'id -> id,
						'name -> name,
						'userId -> userId,
						'parentId -> p_id
					).executeUpdate()
			}
			
			id
		}
	}
	
	def findByUserId(userId:Long): List[Folder] = {
		DB.withConnection { implicit c =>
			SQL("select * from " + tableName + " where user_id = {userId}").on('userId -> userId).as(Folder.simple *)
		}
	}

	def rename(id:Long, name:String) = {
		DB.withConnection { implicit c =>
			SQL("update " + tableName + " set name = {name} where id = {id}").
				on('id -> id, 'name -> name).executeUpdate()
		}
	}
	
	def moveTo(id:Long, parentId:Long) = {
		DB.withConnection { implicit c =>
			SQL("update " + tableName + " set parent_id = {parentId} where id = {id}").
				on('id -> id, 'parentId -> parentId).executeUpdate()
		}
	}
}
