package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class WallPreference(id: Pk[Long], val alias:Option[String], val panX:Double, val panY:Double, val zoom:Double, userId:Long, wallId:Long)


object WallPreference extends ActiveRecord[WallPreference] {
	val tableName = "WallPreference"
		
	val simple = {
		field[Pk[Long]]("id") ~
		field[Option[String]]("alias") ~ 
		field[Double]("pan_x") ~
		field[Double]("pan_y") ~
		field[Double]("zoom") ~
		field[Long]("user_id") ~
		field[Long]("wall_id") map {
			case id ~ name ~ panX ~ panY ~ zoom ~ userId ~ wallId => WallPreference(id, name, panX, panY, zoom, userId, wallId)
		}
	}
	
	def create(userId:Long, wallId:Long, alias:Option[String] = None, panX:Double = 0.0, panY:Double = 0.0, zoom:Double = 1.0) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for wallpreference_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into {tableName} values (
					{id},
					{alias}, {panX}, {panY}, {zoom}, {userId}, {wallId}
				)
			""").on(
				'tableName -> tableName,
				'id -> id,	
				'alias -> alias,
				'panX -> panX,
				'panY -> panY,
				'zoom -> zoom,
				'userId -> userId,
				'wallId -> wallId
			).executeUpdate()
			
			id
		}
	}
	
	def find(userId:Long, wallId:Long) = {
		DB.withConnection { implicit c =>
			SQL("select * from WallPreference where user_id = {userId} and wall_id = {wallId}").on(
			'userId -> userId, 'wallId -> wallId).as(WallPreference.simple.singleOpt)
		}
	}

}

