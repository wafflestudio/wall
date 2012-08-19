package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current



case class GroupWallPermission(groupId:Long, wallId:Long, permission:Int)
case class UserWallPermission(userId:Long, wallId:Long, permission:Int)

object GroupWallPermission extends ActiveRecord[GroupWallPermission]
{
	val tableName = "GroupWallPermission"
		
	val simple = {
		field[Long]("group_id") ~
		field[Long]("wall_id") ~
		field[Int]("permission") map {
			case groupId ~ wallId ~ permission => GroupWallPermission(groupId, wallId, permission)
		}
	}
}

object UserWallPermission extends ActiveRecord[UserWallPermission]
{
	val tableName = "UserWallPermission"
		
	val simple = {
		field[Long]("user_id") ~
		field[Long]("wall_id") ~
		field[Int]("permission") map {
			case userId ~ wallId ~ permission => UserWallPermission(userId, wallId, permission)
		}
	}
}