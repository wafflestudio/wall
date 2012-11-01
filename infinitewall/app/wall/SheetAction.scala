package wall

import play.api.libs.json._

// Action detail
sealed trait ActionDetail {
	val userId:Long
	val timestamp:Long
}

sealed trait ActionDetailWithId extends ActionDetail {
	val id:Long
}

case class CreateAction(userId:Long, timestamp:Long, title:String, contentType:String, content:String, x:Double, y:Double, width:Double, height:Double) extends ActionDetail
case class MoveAction(userId:Long, timestamp:Long, id:Long, x:Double, y:Double) extends ActionDetailWithId
case class ResizeAction(userId:Long, timestamp:Long, id:Long, width:Double, height:Double) extends ActionDetailWithId
case class RemoveAction(userId:Long, timestamp:Long, id:Long) extends ActionDetailWithId
case class SetTitleAction(userId:Long, timestamp:Long, id:Long, title:String) extends ActionDetailWithId
case class SetTextAction(userId:Long, timestamp:Long, id:Long, text:String) extends ActionDetailWithId

// Action detail parser
object ActionDetail {
	def apply(userId:Long, json:JsValue):ActionDetail = {
		val actionType = (json \ "action").as[String]
		val timestamp = (json \ "timestamp").as[Long]
		val params = (json \ "params")
		def id = (params \"id").as[Long]
		def title = (params \ "title").as[String]
		def contentType = (params \ "contentType").as[String]
		def content = (params \ "content").as[String]
		def text = (params \ "text").as[String]
		def x = (params \ "x").as[Double]
		def y = (params \ "y").as[Double]
		def width = (params \ "width").as[Double]
		def height = (params \ "height").as[Double]
		
		if(actionType == "create")
			CreateAction(userId, timestamp, title, contentType, content, x, y, width, height)
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
			}				
		}
	}
}
