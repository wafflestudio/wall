package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB
import ContentType._
import play.api.libs.json._
import play.api.Logger

abstract class Sheet(val id: Pk[Long], val x:Double, val y:Double, val width:Double, val height: Double,  
		val title:String, val contentType:ContentType, val wallId:Long)  {
	
	lazy val wall = {
		Wall.findById(wallId)
	}
	
	lazy val content:Content = {
		contentType match {
			case ContentType.TextType => TextContent.findBySheetId(id.get)
			case ContentType.ImageType => ImageContent.findBySheetId(id.get)
		}
	}
	
	lazy val contentId = {
		contentType match {
			// TODO: can be optimized
			case ContentType.TextType => TextContent.findBySheetId(id.get).id.get
			case ContentType.ImageType => ImageContent.findBySheetId(id.get).id.get	
		}
	}

	def toJson():String
}


class TextSheet(id: Pk[Long], x:Double, y:Double, width:Double, height: Double,  
		title:String, wallId:Long) extends Sheet(id, x, y, width, height, title, ContentType.TextType, wallId) {
	
	def toJson() = {
		JsObject(
			Seq(
				"id" -> JsNumber(id.get),
				"x" -> JsNumber(x),
				"y" -> JsNumber(y),
				"width" -> JsNumber(width),
				"height" -> JsNumber(height),
				"title" -> JsString(title),
				"content" -> JsString(TextContent.findBySheetId(id.get).content),
				"contentType" -> JsString("text")
			)
		).toString()
	}
}

class ImageSheet(id: Pk[Long], x:Double, y:Double, width:Double, height: Double,  
		title:String, wallId:Long) extends Sheet(id, x, y, width, height, title, ContentType.ImageType, wallId) {
	
	def toJson() = {
		JsObject(
			Seq(
				"id" -> JsNumber(id.get),
				"x" -> JsNumber(x),
				"y" -> JsNumber(y),
				"width" -> JsNumber(width),
				"height" -> JsNumber(height),
				"title" -> JsString(title),
				"content" -> JsString(ImageContent.findBySheetId(id.get).url),
				"contentType" -> JsString("image")
			)
		).toString()
	}
}



object Sheet extends ActiveRecord[Sheet] {
	val tableName = "sheet"
		
	val simple = {
		field[Pk[Long]]("id") ~
		field[Double]("x") ~
		field[Double]("y") ~
		field[Double]("width") ~
		field[Double]("height") ~
		field[String]("title") ~
		field[Int]("content_type") ~
		field[Long]("wall_id") ~
		field[Int]("is_reference") map {
			case id ~ x ~ y ~ width ~ height ~ title ~ contentType ~ wallId ~ isReference =>  {
				ContentType(contentType) match {
					case ContentType.TextType =>
						new TextSheet(id, x, y, width, height, title, wallId)
					case ContentType.ImageType => 
						new ImageSheet(id, x, y, width, height, title, wallId)
				}
				
			}
		}
	}

    def createBlank(x: Double, y:Double, width:Double, height:Double, wallId:Long) = {
        DB.withTransaction { implicit c =>
            val id = create(x, y, width, height, "untitled", ContentType.TextType, wallId)
            val contentId = TextContent.create("", 0, 0, id)
            id
        }
    }

	private def create(x:Double, y:Double, width:Double, height: Double, title: String, contentType: ContentType, wallId:Long) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for sheet_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into sheet (id, x, y, width, height, title, content_type, wall_id, is_reference) values (
					{id},
					{x}, {y}, {width}, {height}, {title}, {contentType}, {wallId}, {isReference}
				)
			""").on(
				'id -> id,
				'x -> x,
				'y -> y,
				'width -> width,
				'height -> height,
				'title -> title,
				'contentType -> contentType.id,
				'wallId -> wallId,
				'isReference -> 0
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
		
		DB.withConnection { implicit c =>
			SQL("update " + tableName + " SET x = {x}, y = {y} where id = {id}").on(
					'id -> id,
					'x -> x,
					'y -> y).executeUpdate()
		}
	}
	
	def setText(id: Long, text:String) = {
		TextContent.setText(id, text)
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
