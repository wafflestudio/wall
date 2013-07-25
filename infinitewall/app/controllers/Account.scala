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
}
