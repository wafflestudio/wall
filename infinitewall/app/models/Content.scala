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


case class TextContent(id:Pk[Long], text:String, scrollX:Int, scrollY:Int, sheetId:Long)



//case class ImageContent(binary:Array[Byte]) extends Content