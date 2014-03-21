package controllers

import play.api.Logger
import play.api.Play.current
import play.api.i18n.Lang
import play.api.mvc.Action

object ApplicationController extends Controller with SecureSocial {

	def index = Action { implicit request =>
		Ok(views.html.index())
	}

	def about = Action { implicit request =>
		Ok(views.html.about())
	}

	def logLanguage(implicit lang: Lang) = Logger.info(lang.toString)

	def contribute = Action { implicit request =>
		logLanguage
		Ok(views.html.contribute())
	}

	def contact = Action { implicit request =>
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

	def language(locale: String) = Action { implicit request =>
		Redirect(routes.ApplicationController.index()).withLang(Lang(locale))
	}

	def renewSession() = securedAction { implicit request =>
		Ok("")
	}

}
