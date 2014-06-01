package models

import ActiveRecord._

trait TreeNode

case class RootFolder() extends TreeNode

class Folder(var name: String, var parent: Option[Folder], val user: User) extends Entity {
	def frozen = transactional {
		Folder.Frozen(id, name, parent.map(_.id), user.id)
	}
}

object Folder extends ActiveRecord[Folder] {

	case class Frozen(id: String, name: String, parentId: Option[String], userId: String) extends TreeNode

	def create(name: String, userId: String, parentId: Option[String] = None) = transactional {
		val parent = parentId.map { id =>
			findById(id).get
		}
		val user = User.findById(userId).get
		new Folder(name, parent, user).frozen
	}

	def findAllByUserId(userId: String) = transactional {
		val user = User.findById(userId)
		(select[Folder] where (_.user :== user))
	}

	def rename(id: String, name: String) {
		transactional {
			findById(id).map(_.name = name)
		}
	}

	def moveTo(id: String, parentId: String) {
		transactional {
			val parent = findById(parentId)
			findById(id).map(_.parent = parent)
		}
	}

	def moveToRoot(id: String) {
		transactional {
			findById(id).map(_.parent = None)
		}
	}

	override def delete(id: String) {
		transactional {
			val folder = findById(id)
			val subWalls = select[Wall] where (_.folder :== folder)
			val subFolders = select[Folder] where (_.parent :== folder)
			// collapse subelements
			folder.get.parent match {
				case Some(parent) =>
					subFolders.map(f => moveTo(f.id, parent.id))
					subWalls.map(f => moveTo(f.id, parent.id))
				case None =>
					subFolders.map(f => moveToRoot(f.id))
					subWalls.map(f => moveToRoot(f.id))
			}
			super.delete(id)
		}
	}
}
