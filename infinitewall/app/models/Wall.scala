package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class Wall(id: Pk[Long], val name:String, val panX:Double, val panY:Double, val zoom:Double)

object Wall {
	val simple = {
		get[Pk[Long]]("wall.id") ~
		get[String]("wall.name") ~ 
		get[Double]("wall.pan_x") ~
		get[Double]("wall.pan_y") ~
		get[Double]("wall.zoom") map {
			case id ~ name ~ panX ~ panY ~ zoom => Wall(id, name, panX, panY, zoom)
		}
	}
	
	def findById(id: Long): Option[Wall] = {
		DB.withConnection { implicit c =>
			SQL("select * from Wall where id = {id}").on('id -> id).as(Wall.simple.singleOpt)
		}
	}
	
	def create(name:String, panX:Double, panY:Double, zoom:Double) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				insert into Wall values (
					(select next value for wall_seq),
					{name}, {panX}, {panY}, {zoom}
				)
			""").on(
				'name -> name,
				'panX -> panX,
				'panY -> panY,
				'zoom -> zoom
			).executeUpdate()
		}
	}
	
	def delete(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("delete from Wall where id = {id}").on(
				'id -> id
			).executeUpdate()
		}
	}
	
}