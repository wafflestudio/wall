package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current



case class GroupWallGrant(groupId:Long, wallId:Long, grant:Int)
case class UserWallGrant(userId:Long, wallId:Long, grant:Int)

object GroupWallGrant extends ActiveRecord[GroupWallGrant]
{
	val tableName = "GroupWallGrant"
		
	val simple = {
		field[Long]("group_id") ~
		field[Long]("wall_id") ~
		field[Int]("grant") map {
			case groupId ~ wallId ~ grant => GroupWallGrant(groupId, wallId, grant)
		}
	}
}

object UserWallGrant extends ActiveRecord[UserWallGrant]
{
	val tableName = "UserWallGrant"
		
	val simple = {
		field[Long]("user_id") ~
		field[Long]("wall_id") ~
		field[Int]("grant") map {
			case userId ~ wallId ~ grant => UserWallGrant(userId, wallId, grant)
		}
	}
}