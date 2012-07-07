package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class Sheet(id: Pk[Long], val x:Double, val y:Double, val width:Double, val height: Double, wallId:Long)  {
	lazy val wall = {
		Wall.findById(wallId)
	}
	
	lazy val contents = {
		Content.findBySheetId(id.get)
	}
}

object Sheet extends ActiveRecord[Sheet] {
	val tableName = "sheet"
		
	val simple = {
		get[Pk[Long]]("sheet.id") ~
		get[Double]("sheet.x") ~
		get[Double]("sheet.y") ~
		get[Double]("sheet.width") ~
		get[Double]("sheet.height") ~ 
		get[Long]("sheet.wall_id") map {
			case id ~ x ~ y ~ width ~ height ~ wallId => Sheet(id, x, y, width, height, wallId)
		}
	}
	
	def create(s:Sheet) = create(s.x, s.y, s.width, s.height, s.wallId)
	
	def create(x:Double, y:Double, width:Double, height: Double, wallId:Long) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				insert into sheet values (
					(select next value for sheet_seq),
					{x}, {y}, {width}, {height}, {wallId}
				)
			""").on(
				'x -> x,
				'y -> y,
				'width -> width,
				'height -> height,
				'wallId -> wallId
			).executeUpdate()
		}
	}
	
}