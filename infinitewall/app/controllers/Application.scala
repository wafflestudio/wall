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

object Application extends Controller with Login {

  def index = Action { implicit request =>
    Ok(views.html.index())
  }

  def about = Action { implicit request =>
    Ok(views.html.about()).withLang(Lang("en"))
  }

  def contact = Action { implicit request =>
    Ok(views.html.contact()).withLang(Lang("kr"))
  }
}
