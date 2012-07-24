package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.sql.Timestamp
import java.util.Date

case class ChatRoom(id:Pk[Long], title: String)
case class UserInChatRoom(userId:Long, roomId: Long, time:Long)
case class ChatRoomForWall(id:Pk[Long])


object ChatRoom extends ActiveRecord[ChatRoom] {
	val tableName = "ChatRoom"
		
	val simple = {
		get[Pk[Long]]("ChatRoom.id") ~
		get[String]("ChatRoom.title") map {
			case id ~ title => ChatRoom(id, title)
		}
	}
	
	val users = {
		get[Long]("UserInChatRoom.user_id") ~
		get[Long]("UserInChatRoom.chatroom_id") ~
		get[Long]("UserInChatRoom.time") map {
			case user_id ~ chatroom_id ~ time => UserInChatRoom(user_id, chatroom_id, time)
		}
	}
	
	def create(r:ChatRoom) = create(r.title)
	
	def create(title:String) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for chatroom_seq").as(scalar[Long].single)
			SQL(""" 
				insert into ChatRoom values (
					{id},
					{title}	
				)
			""").on(
				'id -> id,
				'title -> title
			).executeUpdate()
			id
		}
	}
	
	def list() = {
		DB.withConnection { implicit c =>
			SQL("select * from ChatRoom").as(ChatRoom.simple*)
		}	
	}
	
	def findOrCreateForWall(wallId: Long) = {
		DB.withTransaction { implicit c =>
			val maybeChatRoom = SQL("select ChatRoom.* from ChatRoomForWall as crfw, ChatRoom where crfw.chatroom_id = ChatRoom.id and crfw.wall_id = {wallId}").on('wallId -> wallId).
				as(ChatRoom.simple.singleOpt)
				
			maybeChatRoom match {
				case Some(chatroom) =>
					chatroom.id.get
				case None =>
					val chatRoomId = SQL("select next value for chatroom_seq").as(scalar[Long].single)
					SQL(""" 
						insert into ChatRoom values (
							{id},
							{title}	
						)
					""").on(
						'id -> chatRoomId,
						'title -> "<ChatRoom for Wall>"
					).executeUpdate()
					
					val chatRoomForWallId = SQL("select next value for chatroomforwall_seq").as(scalar[Long].single)
					SQL(""" 
						insert into ChatRoomForWall values (					
							{id},
							{wallId},
							{chatRoomId}
						)
					""").on(
						'id -> chatRoomForWallId,
						'wallId -> wallId,
						'chatRoomId -> chatRoomId
					).executeUpdate()
										
					chatRoomId
			}
		}
	}
	
	def addUser(id: Long, user_id: Long) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				merge into UserInChatRoom values (					
					{user_id},
					{id},
					(select next value from userinchatroom_timestamp)
				)
			""").on(
				'user_id -> user_id,
				'id -> id
			).executeUpdate()
		}
	}
	
	def removeUser(id: Long, user_id: Long) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				delete from UserInChatRoom where chatroom_id = {id} and user_id = {user_id}	
			""").on(
				'id -> id,
				'user_id -> user_id
			).executeUpdate()
		}
	}
	
	def listUsers(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("select user.* from UserInChatRoom as uic, User where uic.chatroom_id = {id} and uic.user_id = user.id").on('id -> id).
				as(User.simple*)
		}
	}
	
	


}
