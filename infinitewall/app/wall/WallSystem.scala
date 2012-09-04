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

case class Join(userId: Long, timestamp: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Action(userId: Long, detail: JsValue)

case class Connected(enumerator: Enumerator[JsValue])
case class CannotConnect(msg: String)

case class Message(kind: String, username: String, text: String)

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
				val consumer = Iteratee.foreach[JsValue] { detail: JsValue =>
					wall(wallId) ! Action(userId, detail)
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

		case Action(userId, detail) => {
			(detail \ "action").as[String] match {
				case "create" =>
					val params = (detail \ "params").as[JsObject]
					Logger.info(detail.toString)
					Logger.info(params.toString)
					val sheetId = Sheet.createBlank(params \ "x", params \ "y", params \ "width", params \ "height", wallId)
					notifyAll("action", userId, (detail.as[JsObject] ++ JsObject(Seq("id" -> JsNumber(sheetId)))).toString)
				case action @ _ =>
					Logger.info(detail.toString)
					val params = (detail \ "params").as[JsObject]
					val id = (params \ "id").as[Long]
					Sheet.findById(id) map { sheet =>
						action match {
							case "move" =>
								Sheet.move(sheet.id.get, params \ "x", params \ "y")
							case "resize" =>
								Sheet.resize(sheet.id.get, params \ "width", params \ "height")
							case "remove" =>
								Sheet.delete(sheet.id.get)
							case "setTitle" =>
								Sheet.setTitle(sheet.id.get, (params \ "title").as[String])
							case "setText" =>
								Sheet.setText(sheet.id.get, (params \ "text").as[String])
						}
					}

					notifyAll("action", userId, detail.toString)

			}

		}

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
