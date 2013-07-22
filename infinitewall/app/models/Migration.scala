package models

import net.fwbrasil.activate.entity.Entity
import net.fwbrasil.activate.entity.Alias
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
    createInexistentColumnsForAllEntities
    createReferencesForAllEntities
        .ifNotExists
  }
}
