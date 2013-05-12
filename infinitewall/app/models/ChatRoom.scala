package models

import play.api.Play.current
import ActiveRecord._


class ChatRoom(var title:String, var users:List[User] = List(), var wall:Option[Wall] = None) extends Entity
{
  def frozen() = transactional {
    ChatRoom.Frozen(id, title, users.map(_.id), wall.map(_.id))
  }
}

object ChatRoom extends ActiveRecord[ChatRoom] {
 
  case class Frozen(id: String, title: String, users:List[String], wallId:Option[String])
  
  def create(title: String) = transactional {
    new ChatRoom(title)
  }
 
  def list() = transactional {
    findAll
  }

  def findOrCreateForWall(wallId: String) = transactional {
    val wall = Wall.findById(wallId).get
    transactional {
      val result = select[ChatRoom] where(_.wall :== wall)
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
      val user = User.findById(userId)
      val room = findById(id).get
      if(!room.users.contains(user))
        room.users = room.users ++ user
    }
  }

  def removeUser(id: String, userId: String) {
    transactional {
      val user = User.findById(userId)
      val room = findById(id).get
      
      room.users = room.users.filter(_ != user)
    }
  }

  def listUsers(id: String) = transactional {
    findById(id).map { room =>
      room.users
    }
  }
  
  override def delete(id:String) {
    transactional {
      // remove all chatlogs in the room
      val logs = select[ChatLog] where(_.room.id :== id)
      logs.map(_.delete)
      super.delete(id)
    }
  }

}
