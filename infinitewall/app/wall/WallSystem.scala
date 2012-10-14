package wall

import play.api.libs.iteratee._
import akka.actor._
import akka.util.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.mvc.Result
import java.util.Date
import java.text.SimpleDateFormat
import java.util.Locale
import play.api.Logger
import play.api.libs.json._
import models.User
import models.WallLog
import java.sql.Timestamp
import models.Sheet

// Message
case class Join(userId: Long, timestamp: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Action(json:JsValue, detail:ActionDetail)

case class Connected(enumerator: Enumerator[JsValue])
case class CannotConnect(msg: String)

case class Message(kind: String, username: String, text: String)


// Action detail
sealed trait ActionDetail {
	val userId:Long
}

sealed trait ActionDetailWithId extends ActionDetail {
	val id:Long
}

case class CreateAction(userId:Long, title:String, contentType:String, content:String, x:Double, y:Double, width:Double, height:Double) extends ActionDetail
case class MoveAction(userId:Long, id:Long, x:Double, y:Double) extends ActionDetailWithId
case class ResizeAction(userId:Long, id:Long, width:Double, height:Double) extends ActionDetailWithId
case class RemoveAction(userId:Long, id:Long) extends ActionDetailWithId
case class SetTitleAction(userId:Long, id:Long, title:String) extends ActionDetailWithId
case class SetTextAction(userId:Long, id:Long, text:String) extends ActionDetailWithId

// Action detail parser
object ActionDetail {
	def apply(userId:Long, json:JsValue):ActionDetail = {
		val actionType = (json \ "action").as[String]
		val params = (json \ "params")
		val id = (params \"id").as[Long]
		def title = (params \ "title").as[String]
		def contentType = (params \ "contentType").as[String]
		def content = (params \ "content").as[String]
		def text = (params \ "text").as[String]
		def x = (params \ "x").as[Double]
		def y = (params \ "y").as[Double]
		def width = (params \ "width").as[Double]
		def height = (params \ "height").as[Double]
		
		if(actionType == "create")
			CreateAction(userId, title, contentType, content, x, y, width, height)
		else {		
			actionType match {
				case "move" =>
					MoveAction(userId, id, x, y)
				case "resize" =>
					ResizeAction(userId, id, width, height)
				case "remove" =>
					RemoveAction(userId, id)
				case "setTitle" =>
					SetTitleAction(userId, id, title)
				case "setText" =>
					SetTextAction(userId, id, text)
			}				
		}
	}
}


// Wall System (Delegate + Actor)
object WallSystem {

	implicit val timeout = Timeout(1 second)

	var walls: Map[Long, ActorRef] = Map()

	def wall(wallId: Long): ActorRef = {
		walls.get(wallId) match {
			case Some(wall) => wall
			case None =>
				val newActor = Akka.system.actorOf(Props(new WallActor(wallId)))
				walls = walls + (wallId -> newActor)
				newActor
		}
	}

	def establish(wallId: Long, userId: Long, timestamp: Long): Promise[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

		val joinResult = wall(wallId) ? Join(userId, timestamp)

		joinResult.asPromise.map {
			case Connected(producer) =>
				// Create an Iteratee to consume the feed
				val consumer = Iteratee.foreach[JsValue] { json: JsValue =>
					Logger.info(json.toString)
					wall(wallId) ! Action(json, ActionDetail(userId, json))
				}.mapDone { _ =>
					wall(wallId) ! Quit(userId, producer)
				}

				(consumer, producer)

			case CannotConnect(error) =>

				// Connection error

				// A finished Iteratee sending EOF
				val consumer = Done[JsValue, Unit]((), Input.EOF)

				// Send an error and close the socket
				val producer = Enumerator[JsValue](JsObject(Seq("error" -> JsString(error)))).andThen(Enumerator.enumInput(Input.EOF))

				(consumer, producer)

		}

	}

}

class WallActor(wallId: Long) extends Actor {

	var connections = List.empty[(Long, PushEnumerator[JsValue])]

	def prevLogs(timestamp: Long) = {
		WallLog.list(wallId, timestamp)
	}

	def logMessage(kind: String, userId: Long, message: String) = {
		WallLog.create(kind, wallId, userId, message)
	}
	
	implicit def toDouble(value:JsValue) = { value.as[Double] }
	implicit def toLong(value:JsValue) = { value.as[Long] }

	def receive = {
		case Join(userId, timestamp) => {
			// Create an Enumerator to write to this socket
			val producer = Enumerator.imperative[JsValue]()
			val prev = Enumerator(prevLogs(timestamp).map { walllog => WallLog.walllog2Json(walllog) }: _*)

			if (false /* maximum connection per user constraint here*/ ) {
				sender ! CannotConnect("You have reached your maximum number of connections.")
			}
			else {
				connections = connections :+ (userId, producer)
				sender ! Connected(prev >>> producer)
			}
		}
		case Action(detail, c:CreateAction) => 					
			val sheetId = Sheet.createInit(c.x, c.y, c.width, c.height, c.title, c.contentType, c.content, wallId)
			notifyAll("action", c.userId, (detail.as[JsObject] ++ JsObject(Seq("id" -> JsNumber(sheetId)))).toString)
		case Action(detail, action:ActionDetailWithId) =>
			Sheet.findById(action.id) map { sheet =>
				action match {
					case a:MoveAction =>
						Sheet.move(a.id, a.x, a.y)
					case a:ResizeAction =>
						Sheet.resize(a.id, a.width, a.height)
					case a:RemoveAction =>
						Sheet.delete(a.id)
					case a:SetTitleAction =>
						Sheet.setTitle(a.id, a.title)
					case a:SetTextAction =>
						Sheet.setText(a.id, a.text)
				}
			}
			notifyAll("action", action.userId, detail.toString)

		case Quit(userId, producer) => {
			connections = connections.flatMap { p =>
				if (p eq producer)
					None
				else
					Some(p)
			}
		}

	}

	def notifyAll(kind: String, userId: Long, detail: String) {

		val username = User.findById(userId).get.email

		val logId = logMessage(kind, userId, detail)

		val msg = JsObject(
			Seq(
				"kind" -> JsString(kind),
				"username" -> JsString(username),
				"detail" -> JsString(detail),
				"timestamp" -> JsNumber(logId)
			)
		)

		connections.foreach {
			case (_, producer) => producer.push(msg)
		}

	}

}
