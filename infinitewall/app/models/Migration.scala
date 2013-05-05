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
    
    table[TextContent].createTable(_.customColumn[String]("text","CLOB"))
      
    createTableForAllEntities
      .ifNotExists
    createInexistentColumnsForAllEntities
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

class AddDefaultUser extends Migration {
  def timestamp = 201305121400L
  
  def up = {
    customScript {
      new User(email = "wall@wall.com", hashedPW = User.hashedPW("wallwall"), nickname = "admin", 
          permission = GlobalPermission.Administrator, verified = true)
    }
  }
}

class DevMigration extends ManualMigration {

  def up = {
    createInexistentColumnsForAllEntities
    createReferencesForAllEntities
        .ifNotExists
  }
}
