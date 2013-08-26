package indexing

import akka.actor._
import play.api.libs.json._
import play.api.Logger
import akka.pattern.ask
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.mvc.Result
import models.Sheet
import models.Content
import models.ContentType._
import models.TextContent

abstract class IndexAction
case class IndexWall(wallId: String) extends IndexAction
case class IndexSheet(sheetId: String) extends IndexAction

object SheetIndexSystem {
  var indexes: Map[String, ActorRef] = Map()

  def byId(id: String): Option[ActorRef] = {
    indexes.get(id)
  }

  //Index Measure
  def indexWall(sheetId: String) = {
    Sheet.findById(sheetId) match {
      case Some(s: Sheet) =>
        val wallId = s.wall.id
        index(wallId, IndexWall(wallId))
      case None => None
    }
  }

  def indexSheet(sheetId: String) = {
    index(sheetId, IndexSheet(sheetId))
  }

  //Index Script
  def index(id: String, action: IndexAction) = if(!play.Play.isTest) {
    byId(id) match {
      case Some(actor: ActorRef) =>
        Logger.info("SheetIndexSystem / indexWall : " + id + " is already indexing")
      case None =>
        val newIndexActor = Akka.system.actorOf(Props(new SheetIndexActor()))
        indexes = indexes + (id -> newIndexActor)
        newIndexActor ! action
    }
  }
}


class SheetIndexActor extends Actor {
 
  def createIndex(s: Sheet) = {
    TextContent.findBySheetId(s.id) match {
      case Some(content: TextContent) =>
        SheetIndexManager.create(s.frozen.id, s.frozen.wallId, s.frozen.title, content.frozen.text)
      case None => None
    }
  }


  def receive = {
    case IndexWall(wallId) =>
      Sheet.findAllByWallId(wallId).foreach { s =>
        createIndex(s)
      }

    case IndexSheet(sheetId) =>
      Sheet.findById(sheetId) match {
        case Some(s: Sheet) => createIndex(s)
        case None => None
      }
  }

}
