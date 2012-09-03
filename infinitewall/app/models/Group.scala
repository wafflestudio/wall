package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current


case class Group(id: Pk[Long], name: String, userId:Long)
case class UserInGroup(userId:Long, groupId:Long)

object Group extends ActiveRecord[Group] {
	val tableName = "UserGroup"

	val simple = {
		field[Pk[Long]]("id") ~
		field[String]("name") ~
    field[Long]("user_id") map {
			case id ~ name ~ userId => Group(id, name, userId)
		}
	}

	val users = {
		get[Long]("UserInGroup.user_id") ~
		get[Long]("UserInGroup.group_id") map {
			case user_id ~ group_id => UserInGroup(user_id, group_id)
		}
	}

  def list(userId:Long) = {
    DB.withConnection { implicit c =>
			SQL("select * from "+tableName+" where user_id={userId}").on('userId -> userId).as(Group.simple*)
    }
  }

	def create(name: String, userId:Long) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for usergroup_seq").as(scalar[Long].single)
			SQL("""
		        insert into """+tableName+""" values (
		          {id},
		          {name}, {userId}
		        )
		    """).on(
		    	'id -> id,
		    	'name -> name,
          'userId -> userId
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
	def rename(id:Long, name:String) = {
		DB.withConnection { implicit c =>
			SQL("update "+tableName+" set name = {name} where id = {id}").
				on('id -> id, 'name -> name).executeUpdate()
		}
	}

}
