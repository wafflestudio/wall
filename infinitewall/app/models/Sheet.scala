package models

import ActiveRecord._
import indexing.SheetIndexManager
import play.api.Logger
import play.api.libs.json.Json
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import utils.Operation

class Sheet(var x: Int, var y: Int, var width: Int, var height: Int, var title: String, var wall: Wall, val isReference: Boolean) extends Entity {
	def frozen() = transactional {
		val content = TextContent.findBySheet(id).map(_.asInstanceOf[Content])
			.getOrElse(ImageContent.findBySheet(id).get.asInstanceOf[Content]).frozen
		Sheet.Frozen(id, x, y, width, height, title, content, wall.id)
	}

}

object Sheet extends ActiveRecord[Sheet] {

	case class Frozen(id: String, x: Int, y: Int, width: Int, height: Int, title: String, content: FrozenContent, wallId: String) {
		def toJson() = {
			Json.obj(
				"sheetId" -> id,
				"x" -> x,
				"y" -> y,
				"width" -> width,
				"height" -> height,
				"title" -> title,
				"content" -> content.content,
				"contentType" -> {
					content match {
						case _: TextContent.Frozen => "text"
						case _: ImageContent.Frozen => "image"
						case _ => "misc"
					}
				}).toString()
		}

	}

	def create(x: Int, y: Int, width: Int, height: Int, title: String, contentType: String, content: String, wallId: String) = {
		val sheet =
			transactional {
				val wall = Wall.find(wallId).get
				val newSheet = new Sheet(x, y, width, height, title, wall, false)
				contentType match {
					case "text" => new TextContent(content, 0, 0, newSheet)
					case "image" => new ImageContent(content, width, height, newSheet)
				}
				newSheet
			}
		if (contentType == "text") {
			try {
				SheetIndexManager.create(sheet.frozen.id, wallId, title, content) //indexing
			} catch {
				case e: Throwable => Logger.warn("SheetIndexManager: " + e.getMessage())
			}
		}

		sheet
	}

	def remove(id: String) {
		delete(id)
		try {
			SheetIndexManager.remove(id) //indexing
		} catch {
			case e: Throwable => Logger.warn("SheetIndexManager: " + e.getMessage())
		}
	}

	def findAllByWall(wallId: String) = transactional {
		val wall = byId[Wall](wallId)
		select[Sheet] where (_.wall :== wall)
	}

	def move(id: String, x: Int, y: Int) = transactional {
		find(id).map { sheet =>
			sheet.x = x
			sheet.y = y
		}
	}

	def setText(id: String, text: String) = {
		transactional {
			find(id).map { sheet =>
				TextContent.findBySheet(id).map(_.text = text)
			}
		}
		try {
			SheetIndexManager.setText(id, text) //indexing
		} catch {
			case e: Throwable => Logger.warn("SheetIndexManager: " + e.getMessage())
		}
	}

	def alterText(id: String, operation: Operation) = transactional {
		val baseText = TextContent.findBySheet(id).get.text

		try {
			val (alteredText, undo) = operation.applyAndCreateUndo(baseText)
			Logger.debug("original text:\"" + baseText + "\",altered Text:\"" + alteredText + "\"" + " " + undo.toString())

			setText(id, alteredText)
			(baseText, undo)
		} catch {
			case e: Exception =>
				Logger.error("bad alter text operation:[" + e.getMessage() + "] operation: " + operation + ", baseText" + baseText)
				throw e
		}
	}

	def setTitle(id: String, title: String) = {
		transactional {
			find(id).map(_.title = title)
		}
		try {
			SheetIndexManager.setTitle(id, title) //indexing
		} catch {
			case e: Throwable => Logger.warn("SheetIndexManager: " + e.getMessage())
		}
	}

	def resize(id: String, width: Int, height: Int) = transactional {
		find(id).map { sheet =>
			sheet.width = width
			sheet.height = height
		}
	}

	override def delete(id: String) {
		transactional {
			val sheet = byId[Sheet](id)
			val sheetlinks = select[SheetLink] where (link => (link.fromSheet :== sheet) :|| (link.toSheet :== sheet))
			val contents = select[Content] where (_.sheet :== sheet)
			sheetlinks.map(sheetlink => SheetLink.delete(sheetlink.id))
			contents.map(_.delete)
			super.delete(id)
		}
	}

}
