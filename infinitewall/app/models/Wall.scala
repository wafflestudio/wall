package models

import ActiveRecord._

case class ResourceTree(val node: TreeNode, val children: Seq[ResourceTree])
class ResourceLeaf(node: TreeNode) extends ResourceTree(node, List())

class Wall(var name: String, var user: User, var folder: Option[Folder], var permission: Permission.PermissionValue = Permission.privateWrite) extends Entity {
	def frozen = transactional {
		Wall.Frozen(id, name, user.id, folder.map(_.id), permission)
	}
}

object Wall extends ActiveRecord[Wall] {

	case class Frozen(id: String, val name: String, userId: String, folderId: Option[String], permission: Permission.PermissionValue) extends TreeNode

	def create(userId: String, name: String, folderId: Option[String] = None) = transactional {
		val user = User.find(userId).get
		val folder = folderId.map(Folder.find(_).get)
		new Wall(name, user, folder)
	}

	// only owner can delete the wall
	def deleteForUser(userId: String, id: String) = transactional {
		val walls = select[Wall] where (w => (w.id :== id) :&& (w.user.id :== userId))
		walls.map(wall => delete(wall.id))
	}

	def findAllOwnedByUser(userId: String) = transactional {
		select[Wall] where (_.user.id :== userId)
	}

	def hasEditPermission(id: String, userId: String) = transactional {
		findAllOwnedByUser(userId).exists(_.id == id) || User.getSharedWalls(userId).exists(_.id == id)
	}

	def hasReadPermission(id: String, userId: String) = transactional {
		hasEditPermission(id, userId)
	}

	private def buildSubtree(parentFolder: Folder.Frozen, folders: List[Folder.Frozen], walls: List[Wall.Frozen]): ResourceTree = {
		// search in folders and walls for folder.id as parent_id/folder_id

		val subfolders = for {
			folder <- folders
			parentId <- folder.parentId if parentId == parentFolder.id
		} yield folder

		val containedWalls: List[ResourceTree] = for {
			wall <- walls
			folderId <- wall.folderId if folderId == parentFolder.id
		} yield new ResourceLeaf(wall)

		val containedFolders = subfolders.map { folder =>
			buildSubtree(folder, folders, walls)
		}

		new ResourceTree(parentFolder, containedFolders ++ containedWalls)
	}

	private def buildTree(folders: List[Folder.Frozen], walls: List[Wall.Frozen]): ResourceTree = {
		// folders positioned directly at root
		val subfolders = folders.filter(_.parentId.isEmpty)
		// walls positioned directly at root
		val containedWalls = walls.filter(_.folderId.isEmpty).map(new ResourceLeaf(_))

		val containedFolders = subfolders.map { folder =>
			buildSubtree(folder, folders, walls)
		}

		new ResourceTree(new RootFolder, containedFolders ++ containedWalls)
	}

	def tree(userId: String): ResourceTree = transactional {
		val folders = Folder.findAllByUser(userId).map(_.frozen)
		val walls = Wall.findAllOwnedByUser(userId).map(_.frozen)
		buildTree(folders, walls)
	}

	def rename(id: String, name: String) {
		transactional {
			find(id).map(_.name = name)
		}
	}

	def moveTo(id: String, folderId: String) {
		transactional {
			val folder = Folder.find(folderId)
			find(id).map(_.folder = folder)
		}
	}

	def moveToRoot(id: String) {
		transactional {
			find(id).map(_.folder = None)
		}
	}

	override def delete(id: String) {
		transactional {
			val wall = find(id)
			val sheets = select[Sheet] where (_.wall.id :== id)
			val pref = select[WallPreference] where (_.wall.id :== id)
			val logs = select[WallLog] where (_.wall.id :== id)
			val chatroom = select[ChatRoom] where (_.wall :== wall)
			sheets.map(sheet => Sheet.delete(sheet.id))
			pref.map(p => WallPreference.delete(p.id))
			logs.map(log => WallLog.delete(log.id))
			chatroom.map(room => ChatRoom.delete(room.id))
			super.delete(id)
		}
	}

}
