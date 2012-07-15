package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._

case class WallLog(id: Pk[Long], kind: String, message: String, time: Long, roomId: Long, userId: Long)
case class WallLogWithEmail(id: Pk[Long], kind: String, message: String, time: Long, roomId: Long, email: String)

object WallLog extends ActiveRecord[WallLog] {

	val tableName = "WallLog"

	val simple = {
		get[Pk[Long]]("WallLog.id") ~
			get[String]("WallLog.message") ~
			get[Long]("WallLog.time") ~
			get[Long]("WallLog.wallroom_id") ~
			get[Long]("WallLog.user_id") ~
			get[String]("WallLog.kind") map {
				case id ~ message ~ time ~ roomId ~ userId ~ kind => WallLog(id, kind, message, time, roomId, userId)
			}
	}

	val withEmail = {
		get[Pk[Long]]("WallLog.id") ~
			get[String]("WallLog.message") ~
			get[Long]("WallLog.time") ~
			get[Long]("WallLog.wallroom_id") ~
			get[String]("User.email") ~
			get[String]("WallLog.kind") map {
				case id ~ message ~ time ~ roomId ~ email ~ kind => WallLogWithEmail(id, kind, message, time, roomId, email)
			}
	}

	def list(wallId: Long, timestamp: Long) = {
		DB.withConnection { implicit c =>
			SQL("select Walllog.*,User.email from WallLog,User where WallLog.user_id=User.id and WallLog.wall_id = {wallId} and Walllog.time > {timestamp}").on(
				'wallId -> wallId,
				'timestamp -> timestamp
			).as(withEmail *)
		}
	}

	implicit def walllog2Json(walllog: WallLogWithEmail): JsValue = {

		JsObject(
			Seq(
				"kind" -> JsString(walllog.kind),
				"username" -> JsString(walllog.email),
				"message" -> JsString(walllog.message)
			)
		)
	}

	def create(l: WallLog) = create(l.kind, l.roomId, l.userId, l.message)

	def create(kind: String, wallId: Long, userId: Long, message: String) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for walllog_seq").as(scalar[Long].single)
			SQL(""" 
				insert into WallLog values (
					{id},
					{message}, (select next value for walllog_timestamp), {wallId}, {userId}, {kind}	
				)
			""").on(
				'id -> id,
				'message -> message,
				'wallId -> wallId,
				'userId -> userId,
				'kind -> kind
			).executeUpdate()
			id
		}
	}

}
