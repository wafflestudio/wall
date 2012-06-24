package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.util.Date

case class ChatLog(id: Pk[Long], message: String, time: Date, roomId: Long, userId: Long)

object ChatLog {

	val simple = {
		get[Pk[Long]]("ChatLog.id") ~
		get[String]("ChatLog.message") ~
		get[Date]("ChatLog.time") ~
		get[Long]("ChatLog.chatroom_id") ~
		get[Long]("ChatLog.user_id") map {
			case id ~ message ~ time ~ roomId ~ userId => ChatLog(id, message, time, roomId, userId)
		}
	}

	def findById(id: Long): Option[ChatLog] = {
		DB.withConnection { implicit c =>
			SQL("select * from ChatLog where id = {id}").on('id -> id).as(ChatLog.simple.singleOpt)
		}
	}

	def create(message: String, time: Date, roomId: Long, userId: Long) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				insert into ChatLog values (
					(select next value for chatlog_seq),
					{message}, {time}, {room_id}, {user_id}	
				)
			""").on(
				'message -> message,
				'time -> time,
				'room_id -> roomId,
				'user_id -> roomId
			).executeUpdate()
		}
	}

	def delete(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("delete from ChatLog where id = {id}").on(
				'id -> id
			).executeUpdate()
		}
	}
}