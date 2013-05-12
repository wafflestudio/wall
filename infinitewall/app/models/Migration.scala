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

class AddDefaultUser extends Migration {
  def timestamp = 201305121400L
  
  def up = {
    customScript {
      new User(email = "wall@wall.com", hashedPW = User.hashedPW("wallwall"), nickname = "admin", 
          permission = GlobalPermission.Administrator, verified = true)
    }
  }
}

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

/*
class AddSheetLinkReferences extends Migration {
  def timestamp = 201305121543L
  
  def up = {
    customScript {
      val connection = storage.directAccess
      try {
          connection
              .prepareStatement("""alter table UserInChatRoom add constraint fk_userinchatroom_user_1 foreign key (user_id) references User (id) 
  on delete cascade on update restrict;
alter table UserInChatRoom add constraint fk_userinchatroom_chatroom_1 foreign key (chatroom_id) references ChatRoom (id) 
  on delete cascade on update restrict;""")
              .executeUpdate
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

*/

class DevMigration extends ManualMigration {

  def up = {
    createInexistentColumnsForAllEntities
    createReferencesForAllEntities
        .ifNotExists
  }
}
