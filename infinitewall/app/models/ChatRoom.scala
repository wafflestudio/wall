package models

import org.squeryl.dsl.OneToMany
import org.squeryl.PrimitiveTypeMode._

object ChatRoom {
	def find(id: Long) = InfiniteWallSchema.chatRooms.lookup(id)
}

case class ChatRoom(title: String) extends InfiniteWallObject {
	lazy val logs: OneToMany[ChatLog] = InfiniteWallSchema.roomToChatLog.left(this)
}