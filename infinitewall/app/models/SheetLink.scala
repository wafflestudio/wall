package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB
import ContentType._
import play.api.libs.json._
import play.api.Logger
import org.apache.commons.lang.StringEscapeUtils._

case class SheetLink(id: Pk[Long], from_id: Long, to_id: Long, wall_id: Long) {
  def toJson() = {
    JsObject(
      Seq(
        "id" -> JsNumber(id.get),
        "from_id" -> JsNumber(from_id),
        "to_id" -> JsNumber(to_id),
        "wall_id" -> JsNumber(wall_id)
      )
    ).toString()
  }

}

object SheetLink extends ActiveRecord[SheetLink] {
  val tableName = "sheetlink"

  val simple = {
    field[Pk[Long]]("id") ~
      field[Long]("from_id") ~
      field[Long]("to_id") ~
      field[Long]("wall_id") map {
        case id ~ from_id ~ to_id ~ wall_id => SheetLink(id, from_id, to_id, wall_id)
      }
  }

  def create(id: Long, toId: Long, wallId: Long) = {
    DB.withConnection { implicit c =>
      val seq_id = SQL("select next value for sheet_seq").as(scalar[Long].single)

      SQL("insert into " + tableName + " (id, from_id, to_id, wall_id) values ({id},	{from_id}, {to_id}, {wall_id})").on(
        'id -> seq_id,
        'from_id -> id,
        'to_id -> toId,
        'wall_id -> wallId
      ).executeUpdate()
      seq_id
    }
  }

  def remove(id: Long, toId: Long, wallId: Long) = {
    DB.withConnection { implicit c =>
      SQL("delete from " + tableName + " where from_id={from_id} and to_id={to_id} and wall_id={wall_id}").on(
        'from_id -> id,
        'to_id -> toId,
        'wall_id -> wallId
      ).executeUpdate()
    }
  }

  def findByWallId(wallId: Long) = {
    DB.withConnection { implicit c =>
      SQL("select * from " + tableName + " where wall_id = {wallId}").on('wallId -> wallId).as(simple *)
    }
  }
}
