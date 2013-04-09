package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB
import ContentType._
import play.api.libs.json._
import play.api.Logger
import org.apache.commons.lang.StringEscapeUtils._
import indexing._

abstract class Sheet(val id: Pk[Long], val x: Double, val y: Double, val width: Double, val height: Double,
  val title: String, val contentType: ContentType, val wallId: Long) {

  lazy val wall = {
    Wall.findById(wallId)
  }

  lazy val content: Content = {
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

  def toJson(): String
}

class TextSheet(id: Pk[Long], x: Double, y: Double, width: Double, height: Double,
  title: String, wallId: Long) extends Sheet(id, x, y, width, height, title, ContentType.TextType, wallId) {

  def toJson() = {
    Json.obj(
      "id" -> id.get,
      "x" -> x,
      "y" -> y,
      "width" -> width,
      "height" -> height,
      "title" ->  title,
      "content" -> TextContent.findBySheetId(id.get).content,
      "contentType" -> "text"
    ).toString()
  }
}

class ImageSheet(id: Pk[Long], x: Double, y: Double, width: Double, height: Double,
  title: String, wallId: Long) extends Sheet(id, x, y, width, height, title, ContentType.ImageType, wallId) {

  def toJson() = {
    Json.obj(
      "id" -> id.get,
      "x" -> x,
      "y" -> y,
      "width" -> width,
      "height" -> height,
      "title" -> title, 
      "content" -> ImageContent.findBySheetId(id.get).url,
      "contentType" -> "image"
    ).toString
  }
}

object Sheet extends ActiveRecord[Sheet] {

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
        case id ~ x ~ y ~ width ~ height ~ title ~ contentType ~ wallId ~ isReference => {
          ContentType(contentType) match {
            case ContentType.TextType =>
              new TextSheet(id, x, y, width, height, title, wallId)
            case ContentType.ImageType =>
              new ImageSheet(id, x, y, width, height, title, wallId)
          }

        }
      }
  }

  def createInit(x: Double, y: Double, width: Double, height: Double, title: String, contentType: String, content: String, wallId: Long) = {
    DB.withConnection { implicit c =>
      contentType match {
        case "text" =>
          val id = create(x, y, width, height, title, ContentType.TextType, wallId)
          val contentId = TextContent.create(content, 0, 0, id)
          SheetIndexManager.create(id, wallId, title, content)
          id
        case "image" =>
          val id = create(x, y, width, height, title, ContentType.ImageType, wallId)
          val contentId = ImageContent.create(content, 0, 0, id)
          id
      }
    }
  }

  private def create(x: Double, y: Double, width: Double, height: Double, title: String, contentType: ContentType, wallId: Long) = {
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

  def findByWallId(wallId: Long) = {
    DB.withConnection { implicit c =>
      SQL("select * from " + tableName + " where wall_id = {wallId}").on('wallId -> wallId).as(simple *)
    }
  }

  def move(id: Long, x: Double, y: Double) = {
    DB.withConnection { implicit c =>
      SQL("update " + tableName + " SET x = {x}, y = {y} where id = {id}").on(
        'id -> id,
        'x -> x,
        'y -> y).executeUpdate()
    }
  }

  def setText(id: Long, text: String) = {
    TextContent.setText(id, text)

    SheetIndexManager.setText(id, text)
  }

  def alterText(id: Long, from: Int, length: Int, content: String): (String, String) = {
    val baseText = TextContent.findBySheetId(id).content
    try {
      val alteredText = spliceText(baseText, from, length, content)
      Logger.info("original text:\"" + baseText + "\",altered Text:\"" + alteredText + "\"")
      TextContent.setText(id, alteredText)
      (baseText, alteredText)
    }
    catch {
      case e: Exception =>
        Logger.error("bad alter text operation:" + from + ", " + length + "," + content + " => " + baseText)
        throw e
    }
  }

  def setTitle(id: Long, title: String) = {
    DB.withConnection { implicit c =>
      SQL("update " + tableName + " SET title = {title} where id = {id}").on(
        'id -> id,
        'title -> title).executeUpdate()
    }

    SheetIndexManager.setTitle(id, title)
  }

  def resize(id: Long, width: Double, height: Double) = {
    DB.withConnection { implicit c =>
      SQL("update " + tableName + " SET width = {width}, height = {height} where id = {id}").on(
        'id -> id,
        'width -> width,
        'height -> height).executeUpdate()
    }
  }

  private def spliceText(str: String, offset: Int, remove: Int, content: String) = {
    val p1 = scala.math.min(scala.math.max(0, offset), str.length)
    val p2 = scala.math.min(scala.math.max(0, offset + remove), str.length)

    str.substring(0, p1) + content + str.substring(p2, str.length)

  }

}
