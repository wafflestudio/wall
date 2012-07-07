package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class Sheet(id: Pk[Long], val x:Double, val y:Double, val width:Double, val height: Double, wallId:Long)

object Sheet {
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
	
	def findById(id: Long): Option[Sheet] = {
		DB.withConnection { implicit c =>
			SQL("select * from Sheet where id = {id}").on('id -> id).as(Sheet.simple.singleOpt)
		}
	}
	
	def create(x:Double, y:Double, width:Double, height: Double, wallId:Long) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				insert into Sheet values (
					(select next value for wall_seq),
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
	
	def delete(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("delete from Sheet where id = {id}").on(
				'id -> id
			).executeUpdate()
		}
	}
	
}