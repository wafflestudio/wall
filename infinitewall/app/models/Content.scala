package models

import anorm.Pk

class Content(id:Pk[Long], title:String, contentType:Int, sheetId:Long) {
	
} 

case class TextContent(id:Pk[Long], text:String, scrollX:Int, scrollY:Int, contentId:Long) {
//	val content:Content = Content.findBy
}

//case class ImageContent(binary:Array[Byte]) extends Content