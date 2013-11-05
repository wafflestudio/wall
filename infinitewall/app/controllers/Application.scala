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

object Application extends Controller with securesocial.core.SecureSocial {

	def index = UserAwareAction { implicit request =>
		Ok(views.html.index())
	}

	def about = UserAwareAction { implicit request =>
		Ok(views.html.about())
	}

	def contact = UserAwareAction { implicit request =>
		// (name, facebook account)
		val members: List[(String, String)] = List(
			("Taekmin Kim", "taekmin.kim"),
			("Jaeho Jeon", "serendipitydeity"),
			("Jineok Kim", "Gin1231"),
			("Sungmin Choi", "tini839"),
			("Joosik Yoon", "jooshikyoon"),
			("Won-wook Hong", "wonwook.hong"))
		Ok(views.html.contact(members))
	}

	def language(locale: String) = UserAwareAction { implicit request =>
		Redirect(routes.Application.index()).withLang(Lang(locale))
	}
}
