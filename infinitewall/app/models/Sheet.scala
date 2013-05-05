package models

import play.api.Play.current
import ContentType._
import play.api.libs.json._
import play.api.Logger
import org.apache.commons.lang.StringEscapeUtils._
import indexing._
import ActiveRecord._



class Sheet(var x: Double, var y: Double, var width: Double, var height: Double, var title: String, var wall: Wall, val isReference: Boolean) extends Entity {
  def frozen() = transactional {
    val content = TextContent.findBySheetId(id).map(_.asInstanceOf[Content])
      .getOrElse(ImageContent.findBySheetId(id).get.asInstanceOf[Content]).frozen
    Sheet.Frozen(id, x, y, width, height, title, content, wall.id)
  }

}

object Sheet extends ActiveRecord[Sheet] {

  case class Frozen(id: String, x: Double, y: Double, width: Double, height: Double, title: String, content: FrozenContent, wallId: String) {
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
  
  def create(x: Double, y: Double, width: Double, height: Double, title: String, contentType: String, content: String, wallId: String) = {
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
  

  def move(id: String, x: Double, y: Double) = transactional {
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

  def alterText(id: String, from: Int, length: Int, text: String): (String, String) = transactional {
    val baseText = TextContent.findBySheetId(id).get.text

    try {
      val alteredText = spliceText(baseText, from, length, text)
      Logger.info("original text:\"" + baseText + "\",altered Text:\"" + alteredText + "\"")
      setText(id, alteredText)
      (baseText, alteredText)
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

  def resize(id: String, width: Double, height: Double) = transactional {
    findById(id).map { sheet =>
      sheet.width = width
      sheet.height = height
    }
  }

  private def spliceText(str: String, offset: Int, remove: Int, content: String) = {
    val p1 = scala.math.min(scala.math.max(0, offset), str.length)
    val p2 = scala.math.min(scala.math.max(0, offset + remove), str.length)

    str.substring(0, p1) + content + str.substring(p2, str.length)
  }

}
