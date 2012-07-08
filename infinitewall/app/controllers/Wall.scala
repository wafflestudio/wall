package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import play.api.libs.iteratee._
import play.api.libs.concurrent._
import akka.actor._
import akka.util.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.Play.current

case class Join(userId: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Talk(userId: Long, text: String)
case class NotifyJoin(userId: Long)

case class Connected(enumerator: Enumerator[JsValue])
case class CannotConnect(msg: String)

object WallConnectionManager {
	implicit val timeout = Timeout(1 second)

	lazy val defaultRoom = {
		val roomActor = Akka.system.actorOf(Props[WallSystem])
		roomActor
	}

	def establish(wallId: Long, userId: Long): Promise[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

		val joinResult = defaultRoom ? Join(userId)

		joinResult.asPromise.map {
			case Connected(producer) =>
				// Create an Iteratee to consume the feed
				val consumer = Iteratee.foreach[JsValue] { event: JsValue =>
					defaultRoom ! Talk(userId, (event \ "text").as[String])
				}.mapDone { _ =>
					defaultRoom ! Quit(userId, producer)
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

class WallSystem extends Actor {
	def receive = {
		case _ =>
	}
}

object Wall extends Controller with Auth {
	def create(name: String) = Action { implicit request =>
		val wallId = models.Wall.create(name)
		Ok(Json.toJson(wallId))
	}

	def sync(wallId: Long) = WebSocket.async[JsValue] { request =>
		request.session.get("current_user_id") match {
			case Some(userId) =>
				WallConnectionManager.establish(wallId, userId.toLong)
			case None =>
				val consumer = Done[JsValue, Unit]((), Input.EOF)
				val producer = Enumerator[JsValue](JsObject(Seq("error" -> JsString("Unauthorized")))).andThen(Enumerator.enumInput(Input.EOF))
				Promise.pure(consumer, producer)
		}
	}

	def delete(id: Long) = AuthenticatedAction { implicit request => 
		models.Wall.delete(id)
		Ok(Json.toJson("OK"))
	}
}