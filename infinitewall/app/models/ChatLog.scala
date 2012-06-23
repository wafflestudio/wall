package models

import org.squeryl.KeyedEntity
import java.util.Date

case class ChatLog(roomId: Long, userId:Long, message:String, time:Date) extends InfiniteWallObject 