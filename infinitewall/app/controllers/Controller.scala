package controllers

import play.api.mvc.{ AnyContent, Request, RequestHeader }
import securesocial.core.SecuredRequest

/* wrapper class for better usability */
class Controller extends play.api.mvc.Controller {

	def bodyText(implicit request: Request[AnyContent]) = request.body.asText.get

	def jsonParams(implicit request: Request[AnyContent]) = request.body.asJson.get

	def queryParams(implicit header: RequestHeader) = header.queryString

	def formParams(implicit request: Request[AnyContent]) = request.body.asFormUrlEncoded.get

	def jsonParam(key: String)(implicit request: Request[AnyContent]) = (jsonParams \ key).as[String]

	def queryParam(key: String)(implicit header: RequestHeader) = queryParams(header).get(key).get.head

	def formParam(key: String)(implicit request: Request[AnyContent]) = formParams.get(key).get.head

}

trait SecureSocial extends securesocial.core.SecureSocial { self: Controller =>

	def currentUser(implicit header: RequestHeader) = securesocial.core.SecureSocial.currentUser

	def currentUserId(implicit request: SecuredRequest[AnyContent]) = request.user.identityId.userId

}
