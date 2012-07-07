package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class Content(id:Pk[Long], title:String, contentType:Int, sheetId:Long)  {
	lazy val sheet = {
		Sheet.findById(sheetId)
	}
}


object Content extends ActiveRecord[Content] {
	val tableName = "content"
		
	val simple = {
		get[Pk[Long]]("content.id") ~
		get[String]("content.title") ~
		get[Int]("content.content_type") ~
		get[Long]("content.sheet_id") map {
			case id ~ title ~ contentType ~ sheetId => Content(id, title, contentType, sheetId)
		}
	}
	
	def create(c:Content) = create(c.title, c.contentType, c.sheetId)
	
	def create(title:String, contentType:Int, sheetId:Long) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				insert into Content values (
					(select next value for content_seq),
					{title}, {contentType}, {sheetId}
				)
			""").on(
				'title -> title,
				'contentType -> contentType,
				'sheetId -> sheetId
			).executeUpdate()
		}
	}
	
	def findBySheetId(sheetId:Long) =  {
		DB.withConnection { implicit c =>
			SQL("select * from " + tableName + " where sheetId = {sheetId}").on('sheetId -> sheetId).as(simple *)
		}
	} 
}


object ContentType extends Enumeration {
	type ContentType = Value
	val TextType     = Value(1)
	val ImageType    = Value(2)
}


case class TextContent(id:Pk[Long], text:String, scrollX:Int, scrollY:Int, contentId:Long)



//case class ImageContent(binary:Array[Byte]) extends Content