package integration

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import models.ChatRoom
import models.User
import models.ChatLog
import java.util.Date
import java.sql.Timestamp
import models.ActiveRecord._

class Anorm extends Specification {
  sequential

	"ChatLog in ChatRoom" should {
		"Write Log With create" in {
			running(FakeApplication()) {
        transactional {
        User.signup("test@infinitewall.com", "", "test")
				val Some(admin) = User.findByEmail("test@infinitewall.com").map(_.frozen)
				val roomId = ChatRoom.create("Test Room").frozen.id
				val chatlogId = ChatLog.create("test", roomId, admin.id, "test message", 0).frozen.id
				
				ChatLog.findById(chatlogId).map(_.frozen).map { chatLog =>
					println(chatLog.message)
					println(chatLog.timestamp)
				}
				
				ChatLog.delete(chatlogId)
				ChatRoom.delete(roomId)
				}
				true
			}
		}
		

	}
}
