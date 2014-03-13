package models

import play.api.Play.current
import scala.collection.mutable.HashMap
import scala.collection.immutable.HashMap
import ActiveRecord._

class ResourceTree(val node: TreeNode, val children: Seq[ResourceTree])
class ResourceLeaf(node: TreeNode) extends ResourceTree(node, List())

class Wall(var name: String, var user: User, var folder: Option[Folder], var permission: Permission.PermissionValue = Permission.privateWrite) extends Entity {
	def frozen = transactional {
		Wall.Frozen(id, name, user.id, folder.map(_.id), permission)
	}
}

object Wall extends ActiveRecord[Wall] {

	case class Frozen(id: String, val name: String, userId: String, folderId: Option[String], permission: Permission.PermissionValue) extends TreeNode

	def create(userId: String, name: String, folderId: Option[String] = None) = transactional {
		val user = User.findById(userId).get
		val folder = folderId.map(Folder.findById(_).get)
		new Wall(name, user, folder)
	}

	// only owner can delete the wall
	def deleteByUserId(userId: String, id: String) = transactional {
		val walls = select[Wall] where (w => (w.id :== id) :&& (w.user.id :== userId))
		walls.map { wall =>
			delete(wall.id)
		}
	}

	def findAllOwnedByUserId(userId: String) = transactional {
		select[Wall] where (_.user.id :== userId)
	}

	def hasEditPermission(id: String, userId: String) = transactional {
		findAllOwnedByUserId(userId).exists(_.id == id) || User.listSharedWalls(userId).exists(_.id == id)
	}

	def hasReadPermission(id: String, userId: String) = transactional {
		hasEditPermission(id, userId)
	}

	private def buildSubtree(folder: Folder.Frozen, folders: List[Folder.Frozen], walls: List[Wall.Frozen]): ResourceTree = {
		// search in folders and walls for folder.id as parent_id/folder_id

		val subfolders = for {
			folder <- folders
			parentId <- folder.parentId if parentId == folder.id
		} yield folder

		val containedWalls: List[ResourceTree] = for {
			wall <- walls
			folderId <- wall.folderId if folderId == folder.id
		} yield new ResourceLeaf(wall)

		if (subfolders.isEmpty) {
			new ResourceTree(folder, containedWalls)
		} else {

			val containedFolders = subfolders.map { folder =>
				buildSubtree(folder, folders, walls)
			}

			new ResourceTree(folder, containedFolders ++ containedWalls)
		}
	}

	private def buildTree(folders: List[Folder.Frozen], walls: List[Wall.Frozen]): ResourceTree = {
        // folders positioned directly at root
		val subfolders = folders.flatMap { folder =>
			folder.parentId match {
				case Some(_) => None
				case None => Some(folder)
			}
		}

        // walls positioned directly at root
		val containedWalls = walls.flatMap { wall =>
			wall.folderId match {
				case Some(_) => None
				case None => Some(new ResourceLeaf(wall))
			}
		}

		if (subfolders.isEmpty) {
			new ResourceTree(new RootFolder, containedWalls)
		} else {

			val containedFolders = subfolders.map { folder =>
				buildSubtree(folder, folders, walls)
			}

			new ResourceTree(new RootFolder, containedFolders ++ containedWalls)
		}
	}

	def tree(userId: String): ResourceTree = transactional {
		val folders = Folder.findAllByUserId(userId).map(_.frozen)
		val walls = Wall.findAllOwnedByUserId(userId).map(_.frozen)
		buildTree(folders, walls)
	}

	def rename(id: String, name: String) {
		transactional {
			findById(id).map(_.name = name)
		}
	}

	def moveTo(id: String, folderId: String) {
		transactional {
			val folder = Folder.findById(folderId)
			findById(id).map(_.folder = folder)
		}
	}

	override def delete(id: String) {
		transactional {
			val wall = findById(id)
			val sheets = select[Sheet] where (_.wall.id :== id)
			val pref = select[WallPreference] where (_.wall.id :== id)
			val logs = select[WallLog] where (_.wall.id :== id)
			val chatroom = select[ChatRoom] where (_.wall :== wall)
			sheets.map(_.delete)
			pref.map(_.delete)
			logs.map(_.delete)
			chatroom.map(_.delete)
			wall.map(_.delete)
		}
	}

}
