package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._

case class ChatLog(id: Pk[Long], kind: String, message: String, time: Long, when: Long, roomId: Long, userId: Long)
case class ChatLogWithEmail(id: Pk[Long], kind: String, message: String, time: Long, when: Long, roomId: Long, userId: Long, email: String)

object ChatLog extends ActiveRecord[ChatLog] {

  val tableName = "ChatLog"

  val simple = {
    field[Pk[Long]]("id") ~
      field[String]("message") ~
      field[Long]("time") ~
      field[Long]("when") ~
      field[Long]("chatroom_id") ~
      field[Long]("user_id") ~
      field[String]("kind") map {
        case id ~ message ~ time ~ when ~ roomId ~ userId ~ kind => ChatLog(id, kind, message, time, when, roomId, userId)
      }
  }

  val withEmail = {
    field[Pk[Long]]("id") ~
      field[String]("message") ~
      field[Long]("time") ~
      field[Long]("when") ~
      field[Long]("chatroom_id") ~
      field[Long]("user_id") ~
      get[String]("User.email") ~
      field[String]("kind") map {
        case id ~ message ~ time ~ when ~ roomId ~ userId ~ email ~ kind => ChatLogWithEmail(id, kind, message, time, when, roomId, userId, email)
      }
  }

  def list(roomId: Long, timestamp: Long) = {
    DB.withConnection { implicit c =>
      SQL("select Chatlog.*,User.email from ChatLog,User where ChatLog.user_id=User.id and ChatLog.chatroom_id = {roomId} and Chatlog.time > {timestamp}").on(
        'roomId -> roomId,
        'timestamp -> timestamp
      ).as(withEmail *)
    }
  }

  implicit def chatlog2Json(chatlog: ChatLogWithEmail): JsValue = {
    Json.obj(
      "timestamp" -> chatlog.id.get, 
      "userId" -> chatlog.userId,
      "kind" -> chatlog.kind,
      "email" -> chatlog.email,
      "when" -> chatlog.when,
      "message" -> chatlog.message
    )
    
  }

  def create(kind: String, roomId: Long, userId: Long, message: String, when:Long) = {
    DB.withConnection { implicit c =>
      val id = SQL("select next value for chatlog_seq").as(scalar[Long].single)
      SQL(""" 
				insert into ChatLog (id, message, time, when, chatroom_id, user_id, kind)
					values (
					{id},
					{message}, (select next value for chatlog_timestamp), {when}, {chatroomId}, {userId}, {kind}	
				)
			""").on(
        'id -> id,
        'message -> message,
        'when -> when,
        'chatroomId -> roomId,
        'userId -> userId,
        'kind -> kind
      ).executeUpdate()
      id
    }
  }

}
