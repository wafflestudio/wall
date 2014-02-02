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

	def logLanguage(implicit lang: Lang) = Logger.info(lang.toString)

	def contribute = UserAwareAction { implicit request =>
		logLanguage
		Ok(views.html.contribute())
	}

	def contact = UserAwareAction { implicit request =>
		// (name, facebook account)
		val members: List[(String, String)] = List(
			("Taekmin Kim", "taekmin.kim"),
			("Jaeho Jeon", "serendipitydeity"),
			("Joosik Yoon", "jooshikyoon"),
			("Won-wook Hong", "wonwook.hong"))
		val prevmembers = List(
			("Jineok Kim", "Gin1231"),
			("Sungmin Choi", "tini839"))

		Logger.info(request.acceptLanguages.toString)
		Ok(views.html.contact(members, prevmembers))
	}

	def language(locale: String) = UserAwareAction { implicit request =>
		Redirect(routes.Application.index()).withLang(Lang(locale))
	}

	def language2(lang: String, country: String) = UserAwareAction { implicit request =>
		Redirect(routes.Application.index()).withLang(Lang(lang, country))
	}

}
