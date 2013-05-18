package wall

import play.api.libs.json._
import play.api.Logger
import utils.Operation

// Action detail
sealed trait ActionDetail {
  val userId: String
  val timestamp: Long

  def json = {
    Json.obj("timestamp" -> timestamp)
  }
}

sealed trait ActionDetailWithId extends ActionDetail {
  val id: String

  override def json = {
    super.json ++ Json.obj("params" -> Json.obj("id" -> id))
  }
}

case class Ack(userId: String, timestamp: Long) extends ActionDetail
case class CreateAction(userId: String, timestamp: Long, title: String, contentType: String, content: String, x: Int, y: Int, width: Int, height: Int) extends ActionDetail
case class MoveAction(userId: String, timestamp: Long, id: String, x: Int, y: Int) extends ActionDetailWithId
case class ResizeAction(userId: String, timestamp: Long, id: String, width: Int, height: Int) extends ActionDetailWithId
case class RemoveAction(userId: String, timestamp: Long, id: String) extends ActionDetailWithId
case class SetTitleAction(userId: String, timestamp: Long, id: String, title: String) extends ActionDetailWithId
case class SetTextAction(userId: String, timestamp: Long, id: String, text: String) extends ActionDetailWithId
case class AlterTextAction(userId: String, timestamp: Long, id: String, operations: List[OperationWithState]) extends ActionDetailWithId {

  def singleJson = {
    val last = operations.last
    Json.obj("action" -> "alterText",
      "params" -> Json.obj(
        "from" -> last.op.from,
        "length" -> last.op.length,
        "content" -> last.op.content,
        "msgId" -> last.msgId,
        "id" -> id
      )
    )
  }
}
case class SetLinkAction(userId: String, timestamp: Long, id: String, to_id: String) extends ActionDetailWithId
case class RemoveLinkAction(userId: String, timestamp: Long, id: String, to_id: String) extends ActionDetailWithId

case class OperationWithState(op: Operation, msgId: Long)

// Action detail parser
object ActionDetail {
  def apply(userId: String, json: JsValue): ActionDetail = {
    val actionType = (json \ "action").as[String]
    val timestamp = (json \ "timestamp").as[Long]
    val params = (json \ "params")
    def id = (params \ "id").as[String]
    def title = (params \ "title").as[String]
    def contentType = (params \ "contentType").as[String]
    def content = (params \ "content").as[String]
    def text = (params \ "text").as[String]
    def x = (params \ "x").as[Int]
    def y = (params \ "y").as[Int]
    def width = (params \ "width").as[Int]
    def height = (params \ "height").as[Int]

    def to_id = (params \ "to_id").as[String]
    

    def operations = (params \ "operations").as[List[JsObject]].map { js =>
      val from = (js \ "from").as[Int]
      val length = (js \ "length").as[Int]
      val msgId = (js \ "msgId").as[Long]
      val content = (js \ "content").as[String]

      OperationWithState(Operation(from, length, content), msgId)
    }

    if (actionType == "create")
      CreateAction(userId, timestamp, title, contentType, content, x, y, width, height)
    else if (actionType == "ack")
      Ack(userId, timestamp)
    else {
      actionType match {
        case "move" =>
          MoveAction(userId, timestamp, id, x, y)
        case "resize" =>
          ResizeAction(userId, timestamp, id, width, height)
        case "remove" =>
          RemoveAction(userId, timestamp, id)
        case "setTitle" =>
          SetTitleAction(userId, timestamp, id, title)
        case "setText" =>
          SetTextAction(userId, timestamp, id, text)
        case "alterText" =>
          //Logger.info(content)
          AlterTextAction(userId, timestamp, id, operations)
        case "setLink" =>
          SetLinkAction(userId, timestamp, id, to_id)
        case "removeLink" =>
          RemoveLinkAction(userId, timestamp, id, to_id)

      }
    }
  }
}
