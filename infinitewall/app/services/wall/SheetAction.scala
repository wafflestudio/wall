package services.wall

import play.api.libs.json.{ JsObject, JsValue, Json }
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import play.api.libs.json.__
import utils.Operation

// Action detail
sealed trait ActionDetail {
	val userId: String
	val timestamp: Long
	val uuid: String

	def json = {
		Json.obj("timestamp" -> timestamp)
	}
}

sealed trait ActionDetailWithId extends ActionDetail {
	val sheetId: String

	override def json = {
		val addSheetId = (__ \ "params").json.update(__.read[JsObject].map(_ ++ Json.obj("sheetId" -> sheetId)))
		super.json.validate(addSheetId).get
	}
}

case class Ack(userId: String, uuid: String, timestamp: Long) extends ActionDetail
case class CreateAction(userId: String, uuid: String, timestamp: Long, title: String, contentType: String, content: String, x: Int, y: Int, width: Int, height: Int) extends ActionDetail
//case class CreatedAction(userId: String, connectionId: Int, sheetId: String, timestamp: Long, title: String, contentType: String, content: String, x: Int, y: Int, width: Int, height: Int) extends ActionDetailWithId
//{
//  def this(sheetId:String, c:CreateAction) = this(c.userId, c.connectionId, sheetId, c.timestamp, c.title, c.contentType, c.content, c.x, c.y, c.width, c.height)
//}
case class MoveAction(userId: String, uuid: String, sheetId: String, timestamp: Long, x: Int, y: Int) extends ActionDetailWithId
case class ResizeAction(userId: String, uuid: String, sheetId: String, timestamp: Long, width: Int, height: Int) extends ActionDetailWithId
case class RemoveAction(userId: String, uuid: String, sheetId: String, timestamp: Long) extends ActionDetailWithId
case class SetTitleAction(userId: String, uuid: String, sheetId: String, timestamp: Long, title: String) extends ActionDetailWithId
case class SetTextAction(userId: String, uuid: String, sheetId: String, timestamp: Long, text: String) extends ActionDetailWithId
case class AlterTextAction(userId: String, uuid: String, sheetId: String, timestamp: Long, operations: List[OperationWithState], undoOperation: Operation) extends ActionDetailWithId {

	override def json() = {
		val last = operations.last
		Json.obj("action" -> "alterText",
			"timestamp" -> timestamp,
			"params" -> Json.obj(
				"from" -> last.op.from,
				"length" -> last.op.length,
				"content" -> last.op.content,
				"msgId" -> last.msgId,
				"sheetId" -> sheetId),
			"undo" -> Json.obj(
				"from" -> undoOperation.from,
				"length" -> undoOperation.length,
				"content" -> undoOperation.content),
			"uuid" -> uuid)

	}
}
case class SetLinkAction(userId: String, uuid: String, timestamp: Long, sheetId: String, toSheetId: String) extends ActionDetailWithId
case class RemoveLinkAction(userId: String, uuid: String, timestamp: Long, sheetId: String, toSheetId: String) extends ActionDetailWithId

case class OperationWithState(op: Operation, msgId: Long)

// Action detail parser
object ActionDetail {
	def apply(userId: String, json: JsValue): ActionDetail = {
		val actionType = (json \ "action").as[String]
		val timestamp = (json \ "timestamp").as[Long]
		val params = (json \ "params")
		def sheetId = (params \ "sheetId").as[String]
		def uuid = (json \ "uuid").as[String]
		def title = (params \ "title").as[String]
		def contentType = (params \ "contentType").as[String]
		def content = (params \ "content").as[String]
		def text = (params \ "text").as[String]
		def x = (params \ "x").as[Int]
		def y = (params \ "y").as[Int]
		def width = (params \ "width").as[Int]
		def height = (params \ "height").as[Int]

		def fromSheetId = (params \ "fromSheetId").as[String]
		def toSheetId = (params \ "toSheetId").as[String]

		def operations = (params \ "operations").as[List[JsObject]].map { js =>
			val from = (js \ "from").as[Int]
			val length = (js \ "length").as[Int]
			val msgId = (js \ "msgId").as[Long]
			val content = (js \ "content").as[String]

			OperationWithState(Operation(from, length, content), msgId)
		}

		if (actionType == "create")
			CreateAction(userId, uuid, timestamp, title, contentType, content, x, y, width, height)
		else if (actionType == "ack")
			Ack(userId, uuid, timestamp)
		else {
			actionType match {
				case "move" =>
					MoveAction(userId, uuid, sheetId, timestamp, x, y)
				case "resize" =>
					ResizeAction(userId, uuid, sheetId, timestamp, width, height)
				case "remove" =>
					RemoveAction(userId, uuid, sheetId, timestamp)
				case "setTitle" =>
					SetTitleAction(userId, uuid, sheetId, timestamp, title)
				case "setText" =>
					SetTextAction(userId, uuid, sheetId, timestamp, text)
				case "alterText" =>
					//Logger.info(content)
					AlterTextAction(userId, uuid, sheetId, timestamp, operations, Operation.blank)
				case "setLink" =>
					SetLinkAction(userId, uuid, timestamp, fromSheetId, toSheetId)
				case "removeLink" =>
					RemoveLinkAction(userId, uuid, timestamp, fromSheetId, toSheetId)

			}
		}
	}
}
