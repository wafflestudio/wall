package models

import net.fwbrasil.activate.entity.Entity
import net.fwbrasil.activate.migration.Migration
import models.ActiveRecord._
import play.Logger

class CreateInitialTablesMigration extends Migration {
  def timestamp = 201305062100L

  def up = {
    removeAllEntitiesTables
      .ifExists
	Logger.info("Table up")
    
    // make sure TextContent.text made as large
    table[TextContent].createTable(_.customColumn[String]("text","CLOB"))
      
    createTableForAllEntities
      .ifNotExists
    createInexistentColumnsForAllEntities
    createReferencesForAllEntities
        .ifNotExists
  }
}
class AddIndexToSequencer extends Migration {
  def timestamp = 201305102200L

  def up = {
    table[Sequence]
    .addIndex("name", "nameidx")
    .ifNotExists
  }
}


/*
class AddDefaultUser extends Migration {
  def timestamp = 201305121400L
  
  def up = {
    customScript {
      new User(email = "wall@wall.com", hashedPW = User.hashedPW("wallwall"), permission = GlobalPermission.Administrator)
    }
  }
}
*/

class AddIndexToGroupReferences extends Migration {
  def timestamp = 201305121530L

  def up = {
    table[UserInGroup]
        .addIndex("group", "uig_groupidx")
        .ifNotExists
    table[UserInGroup]
        .addIndex("user", "uig_useridx")
        .ifNotExists
        
    table[WallInGroup]
        .addIndex("group", "wig_groupidx")
        .ifNotExists
    table[WallInGroup]
        .addIndex("wall", "wig_wallidx")
        .ifNotExists
  }
}

class RenameGroupToUserGroup extends Migration {
  def timestamp = 201305232130L

  def up = {
    table("Group")
      .renameTable("UserGroup")
      .ifExists
  }
}


class DevMigration extends ManualMigration {

  def up = {
    createTableForAllEntities
      .ifNotExists
    createInexistentColumnsForAllEntities
    createReferencesForAllEntities
        .ifNotExists
  }
}

class SetNullFieldForUser extends Migration {
  def timestamp = 201307252312L

  def up = {
	  customScript {
		  val connection = storage.directAccess
		  try {
			  val nicknameFieldExists = connection
				  .prepareStatement("select * from information_schema.columns where table_name = 'USER' and column_name = 'NICKNAME'").executeQuery.next
				  if(nicknameFieldExists) {
					  connection
						  .prepareStatement("""
								  update User user set user.ssid = user.email, user.provider = 'userpass', user.firstname = user.nickname, user.lastname = '' where user.ssid is null
								  """).executeUpdate
				  }
			  connection.commit
		  } catch {
			  case e:Throwable =>
				  connection.rollback
				  throw e
		  } finally
			  connection.close
	  }
  }
}
