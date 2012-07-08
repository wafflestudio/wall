package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.util.Date

case class ChatLog(id: Pk[Long], message: String, time: Date, roomId: Long, userId: Long)

object ChatLog extends ActiveRecord[ChatLog] {

	val tableName = "ChatLog"
	
	val simple = {
		get[Pk[Long]]("ChatLog.id") ~
		get[String]("ChatLog.message") ~
		get[Date]("ChatLog.time") ~
		get[Long]("ChatLog.chatroom_id") ~
		get[Long]("ChatLog.user_id") map {
			case id ~ message ~ time ~ roomId ~ userId => ChatLog(id, message, time, roomId, userId)
		}
	}

	def create(l:ChatLog) = create(l.message, l.time, l.roomId, l.userId)

	def create(message: String, time: Date, roomId: Long, userId: Long) = {
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
				'time -> time,
				'room_id -> roomId,
				'user_id -> roomId
			).executeUpdate()
			id
		}
	}

}