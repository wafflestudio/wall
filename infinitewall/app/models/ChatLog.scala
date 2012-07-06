package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._

case class ChatLog(id: Pk[Long], kind: String, message: String, time: Long, roomId: Long, userId: Long)
case class ChatLogWithEmail(id: Pk[Long], kind: String, message: String, time: Long, roomId: Long, email: String)

object ChatLog extends ActiveRecord[ChatLog] {

	val tableName = "ChatLog"
	
	val simple = {
		get[Pk[Long]]("ChatLog.id") ~
			get[String]("ChatLog.message") ~
			get[Long]("ChatLog.time") ~
			get[Long]("ChatLog.chatroom_id") ~
			get[Long]("ChatLog.user_id") ~
			get[String]("ChatLog.kind") map {
				case id ~ message ~ time ~ roomId ~ userId ~ kind => ChatLog(id, kind, message, time, roomId, userId)
			}
	}

	implicit def chatlog2Json(chatlog: ChatLogWithEmail): JsValue = {

		JsObject(
			Seq(
				"kind" -> JsString(chatlog.kind),
				"username" -> JsString(chatlog.email),
				"message" -> JsString(chatlog.message)
			//					
			//					,"members" -> JsArray(
			//						connections.map(ws => JsNumber(ws._1))
			//					)
			)
		)
	}

	def create(l: ChatLog) = create(l.kind, l.roomId, l.userId, l.message)

	def create(kind: String, roomId: Long, userId: Long, message: String) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for wall_seq").as(scalar[Long].single)
			SQL(""" 
				insert into ChatLog values (
					{id},
					{message}, {time}, {room_id}, {user_id}	
				)
			""").on(
				'id -> id,
				'message -> message,
				'roomId -> roomId,
				'userId -> userId,
				'kind -> kind
			).executeUpdate()
			id
		}
	}

}
