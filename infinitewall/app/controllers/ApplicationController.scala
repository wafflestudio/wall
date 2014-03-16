package controllers

import play.api.Logger
import play.api.Play.current
import play.api.i18n.Lang

object ApplicationController extends Controller with SecureSocial {

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
		Redirect(routes.ApplicationController.index()).withLang(Lang(locale))
	}

	def renewSession() = UserAwareAction { implicit request =>
		request.user match {
			case Some(user) =>
				Ok("")
			case None =>
				Unauthorized("")
		}
	}

}
