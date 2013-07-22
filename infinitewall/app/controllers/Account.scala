package controllers

import play.api._
import libs.Files.TemporaryFile
import mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.data.validation.Constraints._
import play.api.Play.current
import views._
import helpers._
import models.User
import models.ActiveRecord
import models.ActiveRecord._

object Account extends Controller with securesocial.core.SecureSocial {
  def index = SecuredAction { implicit request =>
	Ok(views.html.account.index(request.user))
  }

/*
        request.session.get("redirect_uri") match {
          case Some(uri) => Redirect(uri).withSession("redirect_uri" -> "/", "session_token" -> ActiveRecord.sessionToken, "current_user.email" -> user.email, "current_user.id" -> user.id)
          case None => Redirect(routes.Application.index).withSession("session_token" -> ActiveRecord.sessionToken, "current_user.email" -> user.email, "current_user.id" -> user.id)
        }
*/
}
