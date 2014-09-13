package unit.models

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import models.ActiveRecord._
import models.User
import models.ChatRoom
import models.ChatLog

/**
 * User: kindone
 * Date: 13. 1. 27.
 */
class ChatRoomSpec extends Specification {
	sequential

	"ChatLog in ChatRoom" should {
		"be deleted when chatroom is deleted" in {
			running(FakeApplication()) {
				val (roomId, chatlogId) = transactional {

					val Some(user) = User.findAll.map(_.frozen).headOption

					val roomId = ChatRoom.create("Test Room").frozen.id
					val chatlogId = ChatLog.create("test", roomId, user.id, "test message", 0).frozen.id

					ChatLog.find(chatlogId).map { chatLog =>
						println("chatlog is found:" + chatLog.message + ":" + chatLog.timestamp)
					}
					(roomId, chatlogId)
				}

				transactional {
					ChatLog.find(chatlogId).map { chatLog =>
						println("chatlog is still found:" + chatLog.message + ":" + chatLog.timestamp)
					}
					ChatRoom.delete(roomId) // deletes chatlog too
				}

				transactional {
					ChatLog.find(chatlogId) must beNone
				}
			}
		}
	}
}
