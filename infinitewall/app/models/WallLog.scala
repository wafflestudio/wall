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
			get[String]("WallLog.kind") ~
			get[String]("WallLog.message") ~
			get[Long]("WallLog.time") ~
			get[Long]("WallLog.wall_id") ~
			get[Long]("WallLog.user_id") map {
				case id ~ kind ~ message ~ time ~ roomId ~ userId  => WallLog(id, kind, message, time, roomId, userId)
			}
	}

	val withEmail = {
		get[Pk[Long]]("WallLog.id") ~
			get[String]("WallLog.kind") ~
			get[String]("WallLog.message") ~
			get[Long]("WallLog.time") ~
			get[Long]("WallLog.wall_id") ~
			get[String]("User.email") map {
				case id ~ kind ~ message ~ time ~ roomId ~ email => WallLogWithEmail(id, kind, message, time, roomId, email)
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

		JsObject(
			Seq(
				"kind" -> JsString(walllog.kind),
				"username" -> JsString(walllog.email),
				"detail" -> JsString(walllog.message),
				"timestamp" -> JsNumber(walllog.time)
			)
		)
	}

	def create(l: WallLog) = create(l.kind, l.roomId, l.userId, l.message)

	def create(kind: String, wallId: Long, userId: Long, message: String) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for walllog_seq").as(scalar[Long].single)
			SQL(""" 
				insert into WallLog values (
					{id}, {kind}, 
					{message}, (select next value for walllog_timestamp), {wallId}, {userId}
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
	
	def timestamp(wallId:Long) = {
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
