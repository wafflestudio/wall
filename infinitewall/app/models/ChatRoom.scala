package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.util.Date

case class ChatRoom(id:Pk[Long], title: String)


object ChatRoom {
	val simple = {
		get[Pk[Long]]("ChatRoom.id") ~
		get[String]("ChatRoom.title") map {
			case id ~ title => ChatRoom(id, title)
		}
	}

	def findById(id: Long): Option[ChatRoom] = {
		DB.withConnection { implicit c =>
			SQL("select * from ChatRoom where id = {id}").on('id -> id).as(ChatRoom.simple.singleOpt)
		}
	}
	
	def create(chatRoom:ChatRoom) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				insert into ChatRoom values (
					(select next value for chatroom_seq),
					{title}	
				)
			""").on(
				'title -> chatRoom.title
			).executeUpdate()
		}
	}
	
	def delete(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("delete from ChatRoom where id = {id}").on(
				'id -> id
			).executeUpdate()
		}
	}
}
