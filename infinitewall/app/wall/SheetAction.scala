package wall

import play.api.libs.json._
import play.api.Logger
import utils.Operation

// Action detail
sealed trait ActionDetail {
  val userId: String
  val connectionId:Int
  val timestamp: Long

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

case class Ack(userId: String, connectionId: Int, timestamp: Long) extends ActionDetail
case class CreateAction(userId: String, connectionId: Int, timestamp: Long, title: String, contentType: String, content: String, x: Int, y: Int, width: Int, height: Int) extends ActionDetail
//case class CreatedAction(userId: String, connectionId: Int, sheetId: String, timestamp: Long, title: String, contentType: String, content: String, x: Int, y: Int, width: Int, height: Int) extends ActionDetailWithId
//{
//  def this(sheetId:String, c:CreateAction) = this(c.userId, c.connectionId, sheetId, c.timestamp, c.title, c.contentType, c.content, c.x, c.y, c.width, c.height)
//}
case class MoveAction(userId: String, connectionId: Int, sheetId: String,  timestamp: Long, x: Int, y: Int) extends ActionDetailWithId
case class ResizeAction(userId: String, connectionId: Int,sheetId: String,  timestamp: Long, width: Int, height: Int) extends ActionDetailWithId
case class RemoveAction(userId: String, connectionId: Int, sheetId: String, timestamp: Long) extends ActionDetailWithId
case class SetTitleAction(userId: String, connectionId: Int, sheetId: String, timestamp: Long, title: String) extends ActionDetailWithId
case class SetTextAction(userId: String, connectionId: Int, sheetId: String, timestamp: Long, text: String) extends ActionDetailWithId
case class AlterTextAction(userId: String, connectionId: Int, sheetId: String, timestamp: Long, operations: List[OperationWithState], undoOperation:Operation) extends ActionDetailWithId {

  override def json() = {
    val last = operations.last
    Json.obj("action" -> "alterText",
      "timestamp" -> timestamp,
      "params" -> Json.obj(
        "from" -> last.op.from,
        "length" -> last.op.length,
        "content" -> last.op.content,
        "msgId" -> last.msgId,
        "sheetId" -> sheetId
      ), 
      "undo" -> Json.obj(
        "from" -> undoOperation.from,
        "length" -> undoOperation.length,
        "content" -> undoOperation.content
      ),
      "connectionId" -> connectionId
    )
    
  }
}
case class SetLinkAction(userId: String, connectionId:Int, timestamp: Long, sheetId: String, toSheetId: String) extends ActionDetailWithId
case class RemoveLinkAction(userId: String, connectionId:Int, timestamp: Long, sheetId: String, toSheetId: String) extends ActionDetailWithId

case class OperationWithState(op: Operation, msgId: Long)

// Action detail parser
object ActionDetail {
  def apply(userId: String, connectionId: Int, json: JsValue): ActionDetail = {
    val actionType = (json \ "action").as[String]
    val timestamp = (json \ "timestamp").as[Long]
    val params = (json \ "params")
    def sheetId = (params \ "sheetId").as[String]
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
      CreateAction(userId, connectionId, timestamp, title, contentType, content, x, y, width, height)
    else if (actionType == "ack")
      Ack(userId, connectionId, timestamp)
    else {
      actionType match {
        case "move" =>
          MoveAction(userId, connectionId, sheetId, timestamp, x, y)
        case "resize" =>
          ResizeAction(userId, connectionId, sheetId, timestamp, width, height)
        case "remove" =>
          RemoveAction(userId, connectionId, sheetId, timestamp)
        case "setTitle" =>
          SetTitleAction(userId, connectionId, sheetId, timestamp, title)
        case "setText" =>
          SetTextAction(userId, connectionId, sheetId, timestamp, text)
        case "alterText" =>
          //Logger.info(content)
          AlterTextAction(userId, connectionId, sheetId, timestamp, operations, Operation.blank)
        case "setLink" =>
          SetLinkAction(userId, connectionId, timestamp, fromSheetId, toSheetId)
        case "removeLink" =>
          RemoveLinkAction(userId, connectionId, timestamp, fromSheetId, toSheetId)

      }
    }
  }
}
