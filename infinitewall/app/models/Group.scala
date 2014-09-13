package models

import ActiveRecord.{ Alias, Entity, byId, query, select, toAnd, toEntityInstanceEntityValueOption, toIsEqualTo, toStatementValueEntityValue, toStatementValueEntityValueOption, toStringEntityValueOption, transactional, where }

@Alias("UserGroup")
class Group(var name: String, var owner: User) extends Entity {
	def frozen() = transactional {
		Group.Frozen(id, name, owner.id)
	}
}

class UserInGroup(val group: Group, val user: User) extends Entity
class WallInGroup(val group: Group, val wall: Wall) extends Entity

object Group extends ActiveRecord[Group] {

	case class Frozen(id: String, name: String, userId: String)

	def createForUser(name: String, userId: String) = transactional {
		val owner = User.find(userId).get
		new Group(name, owner)
	}

	def findAllOwnedByUser(userId: String) = transactional {
		(select[Group] where (_.owner.id :== userId))
	}

	def findAllHasUser(userId: String) = transactional {
		val user = User.find(userId)
		query {
			(group: Group, uig: UserInGroup) => where((uig.user :== user) :&& (group :== uig.group)) select (group)
		}
	}

	def getUsers(id: String) = transactional {
		val group = find(id).get
		(select[UserInGroup] where (_.group :== group)).map(_.user)
	}

	def getWalls(id: String) = transactional {
		val group = find(id).get
		(select[WallInGroup] where (_.group :== group)).map(_.wall)
	}

	def isValid(id: String, userId: String) = transactional {
		val user = User.find(userId).get
		val isOwner = find(id).exists(_.id == id)
		val isInGroup = !(select[UserInGroup] where (_.user :== user)).isEmpty
		isOwner || isInGroup
	}

	def addUser(id: String, userId: String) {
		transactional {
			val user = User.find(userId).get
			val group = find(id).get
			if ((select[UserInGroup] where (uig => (uig.user :== user) :&& (uig.group :== group))).isEmpty) {
				new UserInGroup(group, user)
			}
		}
	}

	def addWall(id: String, wallId: String) {
		transactional {
			val wall = Wall.find(wallId).get
			val group = find(id).get
			if ((select[WallInGroup] where (wig => (wig.wall :== wall) :&& (wig.group :== group))).isEmpty) {
				new WallInGroup(group, wall)
			}
		}
	}

	def removeUser(id: String, userId: String) {
		transactional {
			val user = User.find(userId).get
			val group = find(id).get
			(select[UserInGroup] where (uig => (uig.user :== user) :&& (uig.group :== group))).map(_.delete)
		}
	}

	def removeWall(id: String, wallId: String) {
		transactional {
			val wall = Wall.find(wallId).get
			val group = find(id).get
			(select[WallInGroup] where (wig => (wig.wall :== wall) :&& (wig.group :== group))).map(_.delete)
		}
	}

	def rename(id: String, name: String) {
		transactional {
			find(id).map(_.name = name)
		}
	}

	override def delete(id: String) {
		transactional {
			val group = byId[Group](id)
			val uig = select[UserInGroup] where (_.group :== group)
			val wig = select[WallInGroup] where (_.group :== group)
			uig.map(_.delete)
			wig.map(_.delete)
			super.delete(id)
		}
	}
}
