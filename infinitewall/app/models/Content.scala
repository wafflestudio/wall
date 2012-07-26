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


case class TextContent(id:Pk[Long], content:String, scrollX:Int, scrollY:Int, sheetId:Long)

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
	
	def create(t:TextContent) = create(t.content, t.scrollX, t.scrollY, t.sheetId)
	
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
}

//case class ImageContent(binary:Array[Byte]) extends Content