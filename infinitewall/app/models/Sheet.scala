package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB
import ContentType._
import play.api.libs.json._
import play.api.Logger

class Sheet(val id: Pk[Long], val x:Double, val y:Double, val width:Double, val height: Double,  
		val title:String, val contentType:ContentType, val wallId:Long)  {
	
	lazy val wall = {
		Wall.findById(wallId)
	}
	
	lazy val content:Either[TextContent,ImageContent] = {
		contentType match {
			case ContentType.TextType => Left(TextContent.findBySheetId(id.get))
			case ContentType.ImageType => Right(ImageContent.findBySheetId(id.get))
		}
	}
	
	def toJson() = {
		JsObject(
			Seq(
				"id" -> JsNumber(id.get),
				"x" -> JsNumber(x),
				"y" -> JsNumber(y),
				"width" -> JsNumber(width),
				"height" -> JsNumber(height),
				"title" -> JsString(title),
				"content" -> JsString(content match {
					case Left(text) => text.content
					case Right(image) => image.url
				}),
				"contentType" -> JsString(content match {
					case Left(_) => "text"
					case Right(_) => "image"
				})
			)
		).toString()
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
            val id = create(x, y, width, height, "untitled", ContentType.TextType, wallId)
            val contentId = TextContent.create("", 0, 0, id)
            id
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
			SQL("select * from " + tableName + " where wall_id = {wallId}").on('wallId -> wallId).as(simple *)
		}
	} 

	
	def move(id:Long, x:Double, y:Double) = {
		Logger.info(x + "," +  y)
		DB.withConnection { implicit c =>
			SQL("update " + tableName + " SET x = {x}, y = {y} where id = {id}").on(
					'id -> id,
					'x -> x,
					'y -> y).executeUpdate()
		}
	}
	
	def resize(id:Long, width:Double, height:Double) = {
		DB.withConnection { implicit c =>
			SQL("update " + tableName + " SET width = {width}, height = {height} where id = {id}").on(
					'id -> id,
					'width -> width,
					'height -> height).executeUpdate()
		}
	}
	
}
