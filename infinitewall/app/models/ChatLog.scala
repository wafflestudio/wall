package models

import ActiveRecord._
import net.fwbrasil.activate.entity.Entity
import play.api.libs.json.{ JsValue, Json }
import play.api.libs.json.Json.toJsFieldJsValueWrapper

object ChatTimestamp extends Sequencer("ChatTimestamp")

class ChatLog(val kind: String, val message: String,
		val timestamp: Long, val when: Long,
		val room: ChatRoom, val user: User) extends Entity {
	def frozen() = transactional {
		ChatLog.Frozen(id, kind, message, timestamp, when, room.id, user.id, user.email, user.firstName + " " + user.lastName)
	}
}

object ChatLog extends ActiveRecord[ChatLog] {

	case class Frozen(id: String, kind: String, message: String, timestamp: Long, when: Long, roomId: String, userId: String, email: String, fullName: String)

	implicit def toJson(chatlog: Frozen): JsValue = {
		Json.obj(
			"timestamp" -> chatlog.timestamp,
			"userId" -> chatlog.userId,
			"kind" -> chatlog.kind,
			"email" -> chatlog.email,
			"nickname" -> chatlog.fullName,
			"when" -> chatlog.when,
			"message" -> chatlog.message)
	}

	def findAllByChatRoom(roomId: String) = transactional {
		val result = query {
			val room = byId[ChatRoom](roomId)
			(chatlog: ChatLog) => where(chatlog.room :== room) select (chatlog) orderBy (chatlog.timestamp desc) limit (20)
		}
		result.reverse
	}

	def findAllByChatRoom(roomId: String, beginTimestamp: Long) = transactional {
		query {
			val room = byId[ChatRoom](roomId)
			(chatLog: ChatLog) => where((chatLog.room :== room) :&& (chatLog.timestamp :>= beginTimestamp)) select (chatLog) orderBy (chatLog.timestamp asc)
		}
	}

	def findAllByChatRoom(roomId: String, beginTimestamp: Long, endTimestamp: Long) = transactional {
		query {
			val room = byId[ChatRoom](roomId)
			(chatLog: ChatLog) => where((chatLog.room :== room) :&& (chatLog.timestamp :>= beginTimestamp) :&& (chatLog.timestamp :<= endTimestamp)) select (chatLog) orderBy (chatLog.timestamp asc)
		}
	}

	def create(kind: String, roomId: String, userId: String, message: String, when: Long) = transactional {
		val timestamp = ChatTimestamp.next
		val room = ChatRoom.find(roomId).get
		val user = User.find(userId).get
		new ChatLog(kind, message, timestamp, when, room, user)
	}

}
