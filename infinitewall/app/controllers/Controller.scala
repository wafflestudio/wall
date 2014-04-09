package controllers

import play.api.mvc._
import securesocial.core.SecuredRequest
import scala.concurrent.Future
import play.api.libs.iteratee._
import play.api.libs.json.JsValue
import play.api.libs.json.Json

/* wrapper class for better usability */
class Controller extends play.api.mvc.Controller {

	def bodyText(implicit request: Request[AnyContent]) = request.body.asText.get

	def jsonParams(implicit request: Request[AnyContent]) = request.body.asJson.get

	def jsonParam(key: String)(implicit request: Request[AnyContent]) = (jsonParams \ key).as[String]

	// params by query (usually used in GET method)
	def queryParams(implicit header: RequestHeader) = header.queryString

	def queryParam(key: String)(implicit header: RequestHeader) = queryParams(header).get(key).get.head

	// form encoding (usually used in POST method)
	def formParams(implicit request: Request[AnyContent]) = request.body.asFormUrlEncoded.get

	def formParam(key: String)(implicit request: Request[AnyContent]) = formParams.get(key).get.head

}

trait SecureSocial extends securesocial.core.SecureSocial { self: Controller =>

	def currentUser(implicit header: RequestHeader) = securesocial.core.SecureSocial.currentUser

	def currentUserId(implicit request: SecuredRequest[AnyContent]) = request.user.identityId.userId

	// wrap SecureSocial's SecuredAction with exception handling 
	def securedAction(block: (SecuredRequest[AnyContent]) => SimpleResult) = {

		SecuredAction { implicit request =>
			try {
				block(request)
			} catch {
				case e: java.util.NoSuchElementException =>
					if (play.Play.isProd)
						Unauthorized
					else
						throw e
				case e: Throwable =>
					if (play.Play.isProd)
						InternalServerError
					else
						throw e
			}
		}
	}

	def securedAction[A](bodyParser: BodyParser[A])(block: (SecuredRequest[A]) => SimpleResult) = {
		SecuredAction(bodyParser) { implicit request =>
			try {
				block(request)
			} catch {
				case e: java.util.NoSuchElementException =>
					if (play.Play.isProd)
						Unauthorized
					else
						throw e
				case e: Throwable =>
					if (play.Play.isProd)
						InternalServerError
					else
						throw e
			}
		}
	}

	def securedWebsocket(block: (RequestHeader) => Future[(Iteratee[JsValue, _], Enumerator[JsValue])]) = WebSocket.async[JsValue] { implicit request =>
		currentUser match {
			case Some(user) =>
				block(request)
			case _ =>
				val consumer = Done[JsValue, Unit]((), Input.EOF)
				val producer = Enumerator[JsValue](Json.obj("error" -> "Unauthorized")).andThen(Enumerator.enumInput(Input.EOF))
				Future.successful(consumer, producer)
		}
	}

}
