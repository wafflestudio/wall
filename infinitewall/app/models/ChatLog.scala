package models


import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._
import net.fwbrasil.activate.entity.Entity
import ActiveRecord._

object ChatTimestamp extends Sequencer("ChatTimestamp")


class ChatLog(val kind: String, val message: String, 
    val timestamp: Long, val when: Long, 
    val room:ChatRoom, val user:User) extends Entity
{
  def frozen() = transactional {
    ChatLog.Frozen(id, kind, message, timestamp, when, room.id, user.id, user.email, user.nickname)
  }
}

object ChatLog extends ActiveRecord[ChatLog] {
  
  case class Frozen(id:String, kind:String, message:String, timestamp:Long, when:Long, roomId:String, userId:String, email:String, nickname:String)
  
  implicit def toJson(chatlog: Frozen): JsValue = {
    Json.obj(
      "timestamp" -> chatlog.timestamp,
      "userId" -> chatlog.userId,
      "kind" -> chatlog.kind,
      "email" -> chatlog.email,
      "nickname" -> chatlog.nickname,
      "when" -> chatlog.when,
      "message" -> chatlog.message
    )
  }
  
  def list(roomId: String) = transactional {
    query {
      (chatlog: ChatLog) => where(chatlog.room.id :== roomId) select(chatlog) orderBy(chatlog.timestamp asc)
    }
  }


  def list(roomId: String, beginTimestamp:Long) = transactional {
    query {
      (chatLog: ChatLog) => where((chatLog.room.id :== roomId) :&& (chatLog.timestamp :>= beginTimestamp)) select(chatLog) orderBy(chatLog.timestamp asc)
    }
  }

  
  def list(roomId: String, beginTimestamp: Long, endTimestamp: Long) = transactional {
    query {
      (chatLog: ChatLog) => where((chatLog.timestamp :>= beginTimestamp) :&& (chatLog.timestamp :<= endTimestamp)) select(chatLog) orderBy(chatLog.timestamp asc)
    }
  }



  def create(kind: String, roomId: String, userId: String, message: String, when:Long) = transactional {
    val timestamp = ChatTimestamp.next
    val room = ChatRoom.findById(roomId).get
    val user = User.findById(userId).get
    new ChatLog(kind, message, timestamp, when, room, user)
  }

}
