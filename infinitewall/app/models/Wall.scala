package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class Wall(id: Pk[Long], val name:String, val panX:Double, val panY:Double, val zoom:Double, userId:Long)

object Wall extends ActiveRecord[Wall] {
	val tableName = "wall"
		
	val simple = {
		get[Pk[Long]]("wall.id") ~
		get[String]("wall.name") ~ 
		get[Double]("wall.pan_x") ~
		get[Double]("wall.pan_y") ~
		get[Double]("wall.zoom") ~
		get[Long]("wall.user_id") map {
			case id ~ name ~ panX ~ panY ~ zoom ~ userId=> Wall(id, name, panX, panY, zoom, userId)
		}
	}
	
	def create(w:Wall) = create(w.userId, w.name, w.panX, w.panY, w.zoom)
	
	def create(userId:Long, name:String, panX:Double = 0.0, panY:Double = 0.0, zoom:Double = 1.0) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for wall_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into Wall values (
					{id},
					{name}, {panX}, {panY}, {zoom}, {userId}
				)
			""").on(
				'id -> id,	
				'name -> name,
				'panX -> panX,
				'panY -> panY,
				'zoom -> zoom,
				'userId -> userId
			).executeUpdate()
			
			id
		}
	}
	
	def list() = {
		DB.withConnection { implicit c =>
			SQL("select * from Wall").as(Wall.simple*)
		}	
	}
	
	
	
}