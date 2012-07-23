package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class WallPreference(id: Pk[Long], val alias:Option[String], val panX:Double, val panY:Double, val zoom:Double, userId:Long, wallId:Long)


object WallPreference extends ActiveRecord[WallPreference] {
	val tableName = "WallPreference"
		
	val simple = {
		get[Pk[Long]]("wallPreference.id") ~
		get[Option[String]]("wallPreference.alias") ~ 
		get[Double]("wallPreference.pan_x") ~
		get[Double]("wallPreference.pan_y") ~
		get[Double]("wallPreference.zoom") ~
		get[Long]("wallPreference.user_id") ~
		get[Long]("wallPreference.wall_id") map {
			case id ~ name ~ panX ~ panY ~ zoom ~ userId ~ wallId => WallPreference(id, name, panX, panY, zoom, userId, wallId)
		}
	}
	
	def create(w:WallPreference) = create(w.userId, w.wallId, w.alias, w.panX, w.panY, w.zoom)
	
	def create(userId:Long, wallId:Long, alias:Option[String] = None, panX:Double = 0.0, panY:Double = 0.0, zoom:Double = 1.0) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for wallpreference_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into WallPreference values (
					{id},
					{alias}, {panX}, {panY}, {zoom}, {userId}, {wallId}
				)
			""").on(
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

