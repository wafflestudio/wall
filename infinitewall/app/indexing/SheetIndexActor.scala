package indexing

import akka.actor._
import models.{ Sheet, TextContent }
import play.api.Logger
import play.api.Play.current
import play.api.libs.concurrent.Akka

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
		Sheet.find(sheetId) match {
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
	def index(id: String, action: IndexAction) = if (!play.Play.isTest) {
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
		TextContent.findBySheet(s.id) match {
			case Some(content: TextContent) =>
				SheetIndexManager.create(s.frozen.id, s.frozen.wallId, s.frozen.title, content.frozen.text)
			case None => None
		}
	}

	def receive = {
		case IndexWall(wallId) =>
			Sheet.findAllByWall(wallId).foreach { s =>
				createIndex(s)
			}

		case IndexSheet(sheetId) =>
			Sheet.find(sheetId) match {
				case Some(s: Sheet) => createIndex(s)
				case None => None
			}
	}

}
