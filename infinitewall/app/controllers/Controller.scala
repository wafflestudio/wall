package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.data.validation.Constraints._
import play.api.libs.concurrent._
import play.api.libs.concurrent.Execution.Implicits._
import play.api.Play.current
import play.api.libs.json.JsValue
import play.api.libs.json.Json
import models.User
import views._
import helpers._
import net.fwbrasil.activate.ActivateContext
import net.fwbrasil.activate.play.EntityForm
import net.fwbrasil.activate.play.EntityForm._
import models.ActiveRecord
import models.ActiveRecord._
import play.api.i18n.Lang
import securesocial.core.{ Identity, Authorization, SecuredRequest }
import play.api.mvc.Request

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

	def currentUserId(implicit request: SecuredRequest[AnyContent]) = request.user.identityId.userId

}
