package models

import org.squeryl.Schema
import org.squeryl.PrimitiveTypeMode._
import org.squeryl.dsl.QueryDsl
import org.squeryl.KeyedEntity

object InfiniteWallSchema extends Schema {
	val users = table[User]
	val chatLogs = table[ChatLog]
	val chatRooms = table[ChatRoom]

	val roomToChatLog =
		oneToManyRelation(chatRooms, chatLogs).
			via((room, log) => room.id === log.roomId)
	
	val userToChatLog = 
		oneToManyRelation(users, chatLogs).via((user, log) => user.id === log.userId)
}

class InfiniteWallObject extends KeyedEntity[Long] {
	val id: Long = 0
}