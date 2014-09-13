package models

import ActiveRecord._

class ChatRoom(var title: String, var users: List[User] = List(), var wall: Option[Wall] = None) extends Entity {
	def frozen() = transactional {
		ChatRoom.Frozen(id, title, users.map(_.id), wall.map(_.id))
	}
}

object ChatRoom extends ActiveRecord[ChatRoom] {

	case class Frozen(id: String, title: String, users: List[String], wallId: Option[String])

	def create(title: String) = transactional {
		new ChatRoom(title)
	}

	def findOrCreateForWall(wallId: String) = transactional {
		val wall = Wall.find(wallId).get
		transactional {
			val result = select[ChatRoom] where (_.wall :== wall)
			result.headOption match {
				case Some(room) =>
					room
				case None =>
					new ChatRoom("forWall", List(), Some(wall))
			}
		}
	}

	def addUser(id: String, userId: String) {
		transactional {
			val user = User.find(userId)
			val room = find(id).get
			if (!room.users.contains(user))
				room.users = room.users ++ user
		}
	}

	def removeUser(id: String, userId: String) {
		transactional {
			val user = User.find(userId)
			val room = find(id).get

			room.users = room.users.filter(_ != user)
		}
	}

	def getUsers(id: String) = transactional {
		find(id).map { room =>
			room.users
		}
	}

	override def delete(id: String) {
		transactional {
			// remove all chatlogs in the room
			val room = byId[ChatRoom](id)
			val logs = select[ChatLog] where (_.room :== room)
			logs.map(log => ChatLog.delete(log.id))
			super.delete(id)
		}
	}

}
