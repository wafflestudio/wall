package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB


object ContentType extends Enumeration {
	type ContentType = Value
	val TextType     = Value(1)
	val ImageType    = Value(2)
}

sealed trait Content

case class TextContent(id:Pk[Long], content:String, scrollX:Int, scrollY:Int, sheetId:Long) extends Content
case class ImageContent(id:Pk[Long], url:String, width:Double, height:Double, sheetId:Long) extends Content

object TextContent extends ActiveRecord[TextContent] {
	val tableName = "TextContent"
		
	val simple = {
		get[Pk[Long]]("TextContent.id") ~
		get[String]("TextContent.content") ~ 
		get[Int]("TextContent.scroll_x") ~ 
		get[Int]("TextContent.scroll_y") ~ 
		get[Long]("TextContent.sheet_id") map {
			case id ~ content ~ scrollX ~ scrollY ~ sheetId => TextContent(id, content, scrollX, scrollY, sheetId)
		}
	}
	
	def create(content:String, scrollX:Int, scrollY:Int, sheetId:Long) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for textcontent_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into textcontent values (
					{id},
					{content}, {scrollX}, {scrollY}, {sheetId}
				)
			""").on(
				'id -> id,
				'content -> content,
				'scrollX -> scrollX,
				'scrollY -> scrollY,
				'sheetId -> sheetId
			).executeUpdate()
			
			id
		}
	}
	
	def setText(sheetId: Long, content:String) = {
		
		DB.withConnection { implicit c =>
			SQL("update " + tableName + " SET content = {content} where sheet_id = {sheetId}").on(
					'sheetId -> sheetId,
					'content -> content).executeUpdate()
		}
	}
	
	def findBySheetId(sheetId:Long) = {
		DB.withConnection { implicit c =>
			SQL("select * from " + tableName + " where sheet_id = {sheetId}").on('sheetId -> sheetId).as(simple.single)
		}
	}
}

object ImageContent extends ActiveRecord[ImageContent] {
	val tableName = "ImageContent"
		
	val simple = {
		field[Pk[Long]]("id") ~
		field[String]("url") ~ 
		field[Int]("width") ~ 
		field[Int]("height") ~ 
		field[Long]("sheet_id") map {
			case id ~ url ~ width ~ height ~ sheetId => ImageContent(id, url, width, height, sheetId)
		}
	}
	
	def create(url:String, width:Double, height:Double, sheetId:Long) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for textcontent_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into textcontent values (
					{id},
					{url}, {width}, {height}, {sheetId}
				)
			""").on(
				'id -> id,
				'url -> url,
				'width -> width,
				'height -> height,
				'sheetId -> sheetId
			).executeUpdate()
			
			id
		}
	}
	
	def findBySheetId(sheetId:Long) = {
		DB.withConnection { implicit c =>
			SQL("select * from " + tableName + " where sheet_id = {sheetId}").on('sheetId -> sheetId).as(simple.single)
		}
	}
	
}