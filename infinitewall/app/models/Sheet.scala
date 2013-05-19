package models

import play.api.Play.current
import ContentType._
import play.api.libs.json._
import play.api.Logger
import org.apache.commons.lang.StringEscapeUtils._
import indexing._
import ActiveRecord._
import utils.Operation



class Sheet(var x: Int, var y: Int, var width: Int, var height: Int, var title: String, var wall: Wall, val isReference: Boolean) extends Entity {
  def frozen() = transactional {
    val content = TextContent.findBySheetId(id).map(_.asInstanceOf[Content])
      .getOrElse(ImageContent.findBySheetId(id).get.asInstanceOf[Content]).frozen
    Sheet.Frozen(id, x, y, width, height, title, content, wall.id)
  }

}

object Sheet extends ActiveRecord[Sheet] {

  case class Frozen(id: String, x: Int, y: Int, width: Int, height: Int, title: String, content: FrozenContent, wallId: String) {
    def toJson() = {
      Json.obj(
        "id" -> id,
        "x" -> x,
        "y" -> y,
        "width" -> width,
        "height" -> height,
        "title" -> title,
        "content" -> content.content,
        "contentType" -> {
          content match {
            case _: TextContent.Frozen => "text"
            case _: ImageContent.Frozen => "image"
            case _ => "misc"
          }
        }
      ).toString()
    }
  
  }
  
  def create(x: Int, y: Int, width: Int, height: Int, title: String, contentType: String, content: String, wallId: String) = {
    val sheet =
      transactional {
        val wall = Wall.findById(wallId).get
        val newSheet = new Sheet(x, y, width, height, title, wall, false)
        contentType match {
          case "text" => new TextContent(content, 0, 0, newSheet)
          case "image" => new ImageContent(content, width, height, newSheet)
        }
        newSheet
      }
    if (contentType == "text")
      SheetIndexManager.create(sheet.frozen.id, wallId, title, content) //indexing

    sheet
  }

  def remove(id: String) {
    delete(id)
    SheetIndexManager.remove(id) //indexing
  }

  def findAllByWallId(wallId: String) = transactional {
    select[Sheet] where (_.wall.id :== wallId)
  }
  

  def move(id: String, x: Int, y: Int) = transactional {
    findById(id).map { sheet =>
      sheet.x = x
      sheet.y = y
    }
  }
  

  def setText(id: String, text: String) = {
    transactional {
      findById(id).map { sheet =>
        TextContent.findBySheetId(id).map(_.text = text)
      }
    }
    SheetIndexManager.setText(id, text) //indexing
  }

  def alterText(id: String, from: Int, length: Int, text: String) = transactional {
    val baseText = TextContent.findBySheetId(id).get.text

    try {
      val (alteredText, undo) = spliceText(baseText, from, length, text)
      Logger.info("original text:\"" + baseText + "\",altered Text:\"" + alteredText + "\"" + " " + undo.toString())
     
      setText(id, alteredText)
      (baseText, alteredText, undo)
    }
    catch {
      case e: Exception =>
        Logger.error("bad alter text operation:" + from + ", " + length + "," + text + " => " + baseText)
        throw e
    }
  }

  def setTitle(id: String, title: String) = {
    transactional {
      findById(id).map(_.title = title)
    }
    SheetIndexManager.setTitle(id, title) //indexing
  }

  def resize(id: String, width: Int, height: Int) = transactional {
    findById(id).map { sheet =>
      sheet.width = width
      sheet.height = height
    }
  }
  
  override def delete(id:String) {
    transactional {
      val sheetlinks = select[SheetLink] where(link => (link.fromSheet.id :== id) :|| (link.toSheet.id :== id))
      val textContents = select[TextContent] where(_.sheet.id :== id)
      val imageContents = select[ImageContent] where(_.sheet.id :== id)
      // TODO: more general content per type delete?
      sheetlinks.map(_.delete)
      textContents.map(_.delete)
      imageContents.map(_.delete)
      super.delete(id)
    }
  }

  private def spliceText(str: String, offset: Int, remove: Int, content: String) = {
    val p1 = scala.math.min(scala.math.max(0, offset), str.length)
    val p2 = scala.math.min(scala.math.max(0, offset + remove), str.length)
    
    assert(p1 == offset)
    assert(p2 == offset + remove)

    val alteredText = str.substring(0, p1) + content + str.substring(p2, str.length)
    val undoOp = {
      val remove_ = content.length
      val p1_ = p1
      val p2_ = scala.math.min(scala.math.max(0, offset + remove_), alteredText.length)
      val content_ = str.substring(p1, p2)
      val originalText = alteredText.substring(0, p1_) + content_ + alteredText.substring(p2_, alteredText.length)
      Logger.info(str + ":" + originalText)
      assert(str == originalText)
      Operation(p1_, remove_, content_)
    }
    
    (alteredText, undoOp)
  }

}
