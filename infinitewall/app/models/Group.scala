package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.sql.Timestamp
import java.util.Date

case class Group(id: Pk[Long], val name: String)

object Group extends ActiveRecord[Group] {
  val tableName = "Group"

  val simple = {
    field[Pk[Long]]("id") ~
    field[String]("name") map {
      case id ~ name => Group(id, name)
    }
  }
/* for run (table is not updated yet)
	val users = {
		get[Long]("UserInGroup.user_id") ~
		get[Long]("UserInGroup.group_id") map {
			case user_id ~ group_id => UserInGroup(user_id, group_id)
		}
	}

  def create(name:String) = {
    DB.withConnection { implicit c =>
      val id = SQL("select next value for group_seq").as(scalar[Long].single)
      SQL("""
        insert into Group values (
          {id},
          {name}
        )
      """).on(
        'id -> id,
        'title -> title
      ).executeUpdate()
      id
    }
  }
	def addUser(id: Long, user_id: Long) = {
		DB.withConnection { implicit c =>
			SQL(""" 
				merge into UserInGroup values (					
					{user_id},
					{id}
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
				delete from UserInGroup where group_id = {id} and user_id = {user_id}	
			""").on(
				'id -> id,
				'user_id -> user_id
			).executeUpdate()
		}
	}
	
	def listUsers(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("select user.* from UserInGroup as uig, User where uig.group_id = {id} and uig.user_id = user.id").on('id -> id).
				as(User.simple*)
		}
	}
  */

}
