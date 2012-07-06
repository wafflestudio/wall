package models

class Content {
	
} 

case class TextContent(text:String) extends Content
case class ImageContent(binary:Array[Byte]) extends Content