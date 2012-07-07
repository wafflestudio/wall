package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class Wall(id: Pk[Long], val name:String, val panX:Double, val panY:Double, val zoom:Double)

object Wall extends ActiveRecord[Wall] {
	val tableName = "wall"
		
	val simple = {
		get[Pk[Long]]("wall.id") ~
		get[String]("wall.name") ~ 
		get[Double]("wall.pan_x") ~
		get[Double]("wall.pan_y") ~
		get[Double]("wall.zoom") map {
			case id ~ name ~ panX ~ panY ~ zoom => Wall(id, name, panX, panY, zoom)
		}
	}
	
	def create(w:Wall) = create(w.name, w.panX, w.panY, w.zoom)
	
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
	
	
}