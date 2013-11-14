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
import securesocial.core.{ Identity, Authorization }

object Sandbox extends Controller {

	// TODO: add filter for production mode
	def editor = Action {
		Ok(views.html.sandbox.editor())
	}
}