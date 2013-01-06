package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB
import scala.collection.mutable.HashMap
import scala.collection.immutable.HashMap


case class Wall(id: Pk[Long], val name: String, userId: Long, folderId: Option[Long]) extends TreeNode

class ResourceTree(val node:TreeNode, val children:Seq[ResourceTree])
class ResourceLeaf(node:TreeNode) extends ResourceTree(node, List())

object Wall extends ActiveRecord[Wall] {
	val tableName = "wall"
		
	val simple = {
		field[Pk[Long]]("id") ~
		field[String]("name") ~
		field[Long]("user_id") ~
		field[Int]("is_reference") ~
		field[Option[Long]]("folder_id") map {
			case id ~ name ~ userId ~ isReference ~ folderId => Wall(id, name, userId, folderId)
		}
	}
	
	def create(userId:Long, name:String) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for wall_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into Wall (id, name, user_id, is_reference) values (
					{id},
					{name}, {userId}, {isReference}
				)
			""").on(
				'id -> id,	
				'name -> name,
				'userId -> userId,
				'isReference -> 0
			).executeUpdate()
			
			id
		}
	}
	
	def create(userId:Long, name:String, folderId:Long) = {
		DB.withConnection { implicit c =>
			val id = SQL("select next value for wall_seq").as(scalar[Long].single)
			
			SQL(""" 
				insert into Wall (id, name, user_id, is_reference, folder_id) values (
					{id},
					{name}, {userId}, {isReference}, {folderId}
				)
			""").on(
				'id -> id,	
				'name -> name,
				'userId -> userId,
				'isReference -> 0,
				'folderId -> folderId
			).executeUpdate()
			
			id
		}
	}
	
	def deleteByUserId(userId: Long, id:Long) = {
		DB.withConnection { implicit c =>
			SQL("delete from " + tableName + " where id = {id} and user_id = {userId}").on(
				'id -> id, 'userId -> userId
			).executeUpdate()
		}
	}
	
	/* Requires privilege */
	def findAll() = {
		DB.withConnection { implicit c =>
			SQL("select * from Wall").as(Wall.simple*)
		}	
	}
	
	def findAllByUserId(userId:Long) = {
		DB.withConnection {  implicit c =>
			SQL("select * from Wall where user_id={userId}").on('userId -> userId).as(Wall.simple*)
		}
	}
	
    private def buildSubtree(folder:Folder, folders:List[Folder],walls:List[Wall]):ResourceTree = {
        // search in folders and walls for folder.id as parent_id/folder_id
        
        val subfolders = for {
            folder <- folders
            parentId <- folder.parentId if parentId == folder.id.get
        } yield folder

        val containedWalls:List[ResourceTree] = for {
            wall <- walls
            folderId <- wall.folderId if folderId == folder.id.get
        } 	yield new ResourceLeaf(wall)

        if(subfolders.isEmpty) {
            new ResourceTree(folder, containedWalls)
        }
        else  {
            
            val containedFolders = subfolders.map { folder =>
                buildSubtree(folder, folders, walls)
            }
          
            new ResourceTree(folder, containedFolders ++ containedWalls)
        }
    }

    private def buildTree(folders:List[Folder], walls:List[Wall]):ResourceTree = {
		
    	val subfolders = folders.flatMap { folder =>
            folder.parentId match {
            	case Some(_) => None
            	case None => Some(folder)
            }
        }

        val containedWalls = walls.flatMap { wall =>
            wall.folderId match {
            	case Some(_) => None
            	case None => Some(new ResourceLeaf(wall))
            }
        }

        if(subfolders.isEmpty) {
            new ResourceTree(new RootFolder, containedWalls)
        }
        else  {
            
            val containedFolders = subfolders.map { folder =>
                buildSubtree(folder, folders, walls)
            }
          
            new ResourceTree(new RootFolder, containedFolders ++ containedWalls)
        }
    }
	
	def tree(userId:Long):ResourceTree = {
		DB.withConnection {  implicit c =>
			val folders = Folder.findByUserId(userId)
			val walls = SQL("select * from Wall where user_id={userId} ORDER BY folder_id asc").on('userId -> userId).as(Wall.simple*)

            buildTree(folders, walls)
		}	
	}
	
	def rename(id:Long, name:String) = {
		DB.withConnection { implicit c =>
			SQL("update " + tableName + " set name = {name} where id = {id}").
				on('id -> id, 'name -> name).executeUpdate()
		}
	}
	
	def moveTo(id:Long, folderId:Long) = {
		DB.withConnection { implicit c =>
			SQL("update " + tableName + " set folder_id = {folderId} where id = {id}").
				on('id -> id, 'folderId -> folderId).executeUpdate()
		}
	}
	
}
