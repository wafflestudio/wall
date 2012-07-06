package test

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import models.ChatRoom
import models.User
import models.ChatLog
import java.util.Date
import java.sql.Timestamp

class Anorm extends Specification {
	"Chatlog model" should {
		"work as expected" in {
			running(FakeApplication()) {

				val Some(admin) = User.findByEmail("admin@infinitewall.com")
				val roomId = ChatRoom.create("Test Room")
				val chatlogId = ChatLog.create(roomId, admin.id.get, "test message")
				
				ChatLog.findById(chatlogId).map { chatLog =>
					println(chatLog.message)
					println(chatLog.time)
				}
				
				ChatLog.delete(chatlogId)
				ChatRoom.delete(roomId)
				
				true
			}
		}
	}
}
