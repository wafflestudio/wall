package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._

case class ChatLog(id: Pk[Long], kind: String, message: String, time: Long, when: Long, roomId: Long, userId: Long)
case class ChatLogWithUser(id: Pk[Long], kind: String, message: String, time: Long, when: Long, roomId: Long, userId: Long, email: String, nickname: String)

object ChatLog extends ActiveRecord[ChatLog] {

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
      get[String]("User.nickname") ~
      field[String]("kind") map {
        case id ~ message ~ time ~ when ~ roomId ~ userId ~ email ~ nickname ~ kind => ChatLogWithUser(id, kind, message, time, when, roomId, userId, email, nickname)
      }
  }
  
  def list(roomId: Long) = {
    // list all, along with required fields
    DB.withConnection { implicit c =>
      SQL("select Chatlog.*,User.email,User.nickname from ChatLog,User where ChatLog.user_id=User.id and ChatLog.chatroom_id = {roomId} order by ChatLog.time desc limit 30").on(
        'roomId -> roomId
      ).as(withEmail *).reverse
    }
  }

  def list(roomId: Long, beginTimestamp:Long) = {
    DB.withConnection { implicit c =>
      SQL("select Chatlog.*,User.email,User.nickname from ChatLog,User where ChatLog.user_id=User.id and ChatLog.chatroom_id = {roomId} and Chatlog.time >= {beginTimestamp} order by ChatLog.time asc").on(
        'roomId -> roomId,
        'beginTimestamp -> beginTimestamp
      ).as(withEmail *)
    }
  }
  
  def list(roomId: Long, beginTimestamp: Long, endTimestamp: Long) = {
    DB.withConnection { implicit c =>
      SQL("select Chatlog.*,User.email,User.nickname from ChatLog,User where ChatLog.user_id=User.id and ChatLog.chatroom_id = {roomId} and Chatlog.time >= {beginTimestamp} and Chatlog.time <= {endTimestamp}  order by ChatLog.time asc").on(
        'roomId -> roomId,
        'beginTimestamp -> beginTimestamp,
        'endTimestamp -> endTimestamp
      ).as(withEmail *)
    }
  }

  implicit def chatlog2Json(chatlog: ChatLogWithUser): JsValue = {
    Json.obj(
      "timestamp" -> chatlog.id.get, 
      "userId" -> chatlog.userId,
      "kind" -> chatlog.kind,
      "email" -> chatlog.email,
      "nickname" -> chatlog.nickname,
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
