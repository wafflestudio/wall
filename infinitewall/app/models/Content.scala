package models


import play.api.Play.current
import ActiveRecord._

object ContentType extends Enumeration {
  case class ContentType(name:String) extends Val(name)
  
  val TextType = ContentType("text")
  val ImageType = ContentType("image")
}

sealed trait FrozenContent
{
  def content:String
}


abstract class Content extends Entity {
  def frozen:FrozenContent
}

class TextContent(var text:String, var scrollX:Int, var scrollY:Int, val sheet:Sheet) extends Content
{
  def frozen = transactional {
    TextContent.Frozen(id, text, scrollX, scrollY, sheet.id)
  }
 
}

class ImageContent(var url:String, var width:Double, var height:Double, val sheet:Sheet) extends Content
{
  def frozen = transactional {
    ImageContent.Frozen(id, url, width, height, sheet.id)
  }
}


object TextContent extends ActiveRecord[TextContent] {
  
  case class Frozen(id: String, text: String, scrollX: Int, scrollY: Int, sheetId: String) extends FrozenContent
  {
    def content = text
  }
  
  def create(text: String, scrollX: Int, scrollY: Int, sheetId: String) = transactional {
    val sheet = Sheet.findById(sheetId).get
    new TextContent(text, scrollX, scrollY, sheet)
  }

  def setText(id: String, text: String) = transactional {
    findById(id).get.text = text
  }

  def findBySheetId(sheetId:String) = transactional {
    (select[TextContent] where(_.sheet.id :== sheetId)).headOption
  }
  
}

object ImageContent extends ActiveRecord[ImageContent] {
  
  case class Frozen(id: String, url: String, width: Double, height: Double, sheetId: String) extends FrozenContent
  {
    def content = url
  }
  
  def create(url: String, width: Double, height: Double, sheetId: String) = transactional {
    val sheet = Sheet.findById(sheetId).get
    new ImageContent(url, width, height, sheet)
  }
  
  def findBySheetId(sheetId:String) = transactional {
    (select[ImageContent] where(_.sheet.id :== sheetId)).headOption
  }

}
