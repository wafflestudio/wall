package models

import ActiveRecord._
import play.api.libs.json.Json
import play.api.libs.json.Json.toJsFieldJsValueWrapper

class SheetLink(val fromSheet: Sheet, val toSheet: Sheet, var wall: Wall) extends Entity {
	def frozen = transactional {
		SheetLink.Frozen(id, fromSheet.id, toSheet.id, wall.id)
	}
}

object SheetLink extends ActiveRecord[SheetLink] {

	case class Frozen(id: String, fromId: String, toId: String, wallId: String) {
		def toJson() = {
			Json.obj(
				"id" -> id,
				"sheetId" -> fromId,
				"fromSheetId" -> fromId, // added redundancy... remove?
				"toSheetId" -> toId,
				"wall_id" -> wallId).toString()
		}
	}

	def create(fromId: String, toId: String, wallId: String) = transactional {
		val fromSheet = Sheet.find(fromId).get
		val toSheet = Sheet.find(toId).get
		val wall = Wall.find(wallId).get
		new SheetLink(fromSheet, toSheet, wall).id
	}

	def remove(fromId: String, toId: String) {
		transactional {
			val fromSheet = byId[Sheet](fromId)
			val toSheet = byId[Sheet](toId)
			val entities = select[SheetLink] where (link =>
				(link.fromSheet :== fromSheet) :&& (link.toSheet :== toSheet))
			entities.map(_.delete)
		}
	}

	def findAllByWall(wallId: String) = transactional {
		val wall = byId[Wall](wallId)
		select[SheetLink] where (_.wall :== wall)
	}

}
