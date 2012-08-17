package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class Wall(id: Pk[Long], val name:String, userId:Long)

object Wall extends ActiveRecord[Wall] {
	val tableName = "wall"
		
	val simple = {
		field[Pk[Long]]("id") ~
		field[String]("name") ~ 
		field[Long]("user_id") ~
		field[Int]("is_reference") map {
			case id ~ name ~ userId ~ isReference => Wall(id, name, userId)
		}
	}
	
	def create(userId:Long, name:String) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for wall_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into Wall (id, name, user_id, is_reference) values (
					{id},
					{name}, {userId}, {isReference}
				)
			""").on(
				'id -> id,	
				'name -> name,
				'userId -> userId,
				'isReference -> 0
			).executeUpdate()
			
			id
		}
	}
	
	def list() = {
		DB.withConnection { implicit c =>
			SQL("select * from Wall").as(Wall.simple*)
		}	
	}
	
	def tree(userId:Long) = {
		DB.withConnection {  implicit c =>
			val folders = Folder.findByUserId(userId)
			val walls = SQL("select * from Wall where user_id={userId}").on('userId -> userId).as(Wall.simple*)
			
			
		}	
	}
	
	
	
}