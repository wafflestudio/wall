package models

import anorm._

import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB
import ContentType._

class Sheet(val id: Pk[Long], val x:Double, val y:Double, val width:Double, val height: Double,  
		val title:String, val contentType:ContentType, val wallId:Long)  {
	
	lazy val wall = {
		Wall.findById(wallId)
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
		get[String]("sheet.title") ~
		get[Int]("sheet.content_type") ~
		get[Long]("sheet.wall_id") map {
			case id ~ x ~ y ~ width ~ height ~ title ~ contentType ~ wallId => 
				new Sheet(id, x, y, width, height, title, ContentType(contentType), wallId)
		}
	}

    def createBlankText(x: Double, y:Double, width:Double, height:Double, wallId:Long) = {
        DB.withTransaction { implicit c =>
            create(x, y, width, height, "untitled", ContentType.TextType, wallId)
            // TODO: create text content
        }
    }

	def create(s:Sheet) = create(s.x, s.y, s.width, s.height, s.title, s.contentType, s.wallId)
	
	def create(x:Double, y:Double, width:Double, height: Double, title: String, contentType: ContentType, wallId:Long) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for sheet_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into sheet values (
					{id},
					{x}, {y}, {width}, {height}, {title}, {contentType}, {wallId}
				)
			""").on(
				'id -> id,
				'x -> x,
				'y -> y,
				'width -> width,
				'height -> height,
				'title -> title,
				'contentType -> contentType.id,
				'wallId -> wallId
			).executeUpdate()
			
			id
		}
	}
	
	def findByWallId(wallId:Long) =  {
		DB.withConnection { implicit c =>
			SQL("select * from " + tableName + " where wallId = {wallId}").on('wallId -> wallId).as(simple *)
		}
	} 
	
	def nextId(wallId: Long) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for sheet_seq").as(scalar[Long].single)
			
			id
		}
	}
	
	def move(id:Long, x:Double, y:Double) = {
		
	}
	
	def resize(id:Long, width:Double, height:Double) = {
		
	}
	
}
