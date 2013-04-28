package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._

case class WallLog(id: Pk[Long], kind: String, message: String, time: Long, basetime: Long, roomId: Long, userId: Long)
case class WallLogWithEmail(id: Pk[Long], kind: String, message: String, time: Long, basetime: Long, roomId: Long, email: String)

object WallLog extends ActiveRecord[WallLog] {

  val simple = {
    field[Pk[Long]]("id") ~
      field[String]("kind") ~
      field[String]("message") ~
      field[Long]("time") ~
      field[Long]("basetime") ~
      field[Long]("wall_id") ~
      field[Long]("user_id") map {
        case id ~ kind ~ message ~ time ~ basetime ~ roomId ~ userId => WallLog(id, kind, message, time, basetime, roomId, userId)
      }
  }

  val withEmail = {
    field[Pk[Long]]("id") ~
      field[String]("kind") ~
      field[String]("message") ~
      field[Long]("time") ~
      field[Long]("basetime") ~
      field[Long]("wall_id") ~
      get[String]("User.email") map {
        case id ~ kind ~ message ~ time ~ basetime ~ roomId ~ email => WallLogWithEmail(id, kind, message, time, basetime, roomId, email)
      }
  }

  def list(wallId: Long, timestamp: Long) = {
    DB.withConnection { implicit c =>
      SQL("select Walllog.*,User.email from WallLog,User where WallLog.user_id=User.id and WallLog.wall_id = {wallId} and Walllog.time > {timestamp} order by Walllog.time").on(
        'wallId -> wallId,
        'timestamp -> timestamp
      ).as(withEmail *)
    }
  }

  implicit def walllog2Json(walllog: WallLogWithEmail): JsValue = {

    Json.obj(
      "kind" -> walllog.kind,
      "username" -> walllog.email,
      "detail" -> walllog.message,
      "timestamp" -> walllog.time,
      "basetimestamp" -> walllog.basetime
    )
  }

  def create(kind: String, wallId: Long, basetime: Long, userId: Long, message: String) = {
    DB.withConnection { implicit c =>
      val id = SQL("select next value for walllog_seq").as(scalar[Long].single)
      SQL(""" 
        insert into WallLog (id, kind, message, time, basetime, wall_id, user_id) values (
          {id}, {kind}, 
          {message}, (select next value for walllog_timestamp), {basetime}, {wallId}, {userId}
        )""").on(
        'id -> id,
        'message -> message,
        'basetime -> basetime,
        'wallId -> wallId,
        'userId -> userId,
        'kind -> kind
      ).executeUpdate()
      id
    }
  }

  def timestamp(wallId: Long) = {
    DB.withConnection { implicit c =>
      SQL("select MAX(time) from WallLog where wall_id = {wallId}").on(
        'wallId -> wallId
      ).as(scalar[Option[Long]].single) match {
          case Some(time) => time
          case None => 999
        }
    }
  }

}
