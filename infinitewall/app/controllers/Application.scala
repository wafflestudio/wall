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

case class LoginData(val email: String, val password: String)
case class SignUpData(val email: String, val password: String, val nickname: String)
case class CurrentUser(val userId:String , val email: String)

trait Auth {
  self: Controller =>

  def currentUser[Content <: AnyContent](implicit request: { def session:Session }): String = {
    request.session.get("current_user").getOrElse("default")
  }

  def currentUserId[Content <: AnyContent](implicit request: { def session:Session }): String = {
    currentUserIdOption.getOrElse("UNAUTHORIZED")
  }
  
  def currentUserIdOption[Content <: AnyContent](implicit request: { def session:Session } ) = {
    request.session.get("current_user_id")
  }

  def currentUserNickname(implicit request: Request[AnyContent]): String = {
    // TODO: cache
    transactional {
      User.findById(currentUserId).get.nickname
    }
  }

  def currentUserPicturePath(implicit request: Request[AnyContent]) = {
    User.getPictureOrGravatarUrl(currentUserId)
  }

  def AuthenticatedAction(f: Request[AnyContent] => Result): Action[AnyContent] =
    Action { implicit request =>
      if (isSessionTokenValid && request.session.get("current_user").isDefined)
        f(request)
      else {
        Logger.info("unauthorized access:" + request.uri)
        Redirect(routes.Application.index).flashing("error" -> "Please sign in first to access this url").withSession("redirect_uri" -> request.uri)
      }
    }

  def AuthenticatedAction[A](bodyParser: BodyParser[A])(f: Request[A] => Result): Action[A] =
    Action(bodyParser) { implicit request =>
      if (isSessionTokenValid && request.session.get("current_user").isDefined)
        f(request)
      else {
        Logger.info("unauthorized access:" + request.uri)
        Redirect(routes.Application.index).flashing("error" -> "Please sign in first to access this url").withSession("redirect_uri" -> request.uri)
      }
    }

  def isSessionTokenValid[A](implicit request: Request[A]) = {
    request.session.get("session_token").isDefined && request.session.get("session_token").get == ActiveRecord.sessionToken
  }

}

trait Login extends Auth {
  self: Controller =>

  implicit val loginForm = Form {
    mapping("email" -> nonEmptyText, "password" -> text)(LoginData.apply)(LoginData.unapply)
      .verifying("Invalid username or password",
        loginData => User.authenticate(loginData.email, loginData.password).isDefined
      )
  }
}

object Application extends Controller with Login {

  def index = Action { implicit request =>
    Ok(views.html.index())
  }

  def walls = AuthenticatedAction { implicit request =>
    Ok(views.html.index())
  }

  def about = Action { implicit request =>
    Ok(views.html.about())
  }
  def contact = Action { implicit request =>
    Ok(views.html.contact())
  }

  def authenticate = Action { implicit request =>
    loginForm.bindFromRequest.fold(
      formWithErrors => {
        Redirect(routes.Application.index).flashing("error" -> "Bad username or password")
      },
      loginData => {
        val user = transactional { 
          User.findByEmail(loginData.email).get.frozen
        }
        request.session.get("redirect_uri") match {
          case Some(uri) => Redirect(uri).withSession("redirect_uri" -> "/", "session_token" -> ActiveRecord.sessionToken, "current_user" -> user.email, "current_user_id" -> user.id)
          case None => Redirect(routes.Application.index).withSession("session_token" -> ActiveRecord.sessionToken, "current_user" -> user.email, "current_user_id" -> user.id)
        }
      }
    )
  }

  def logout = AuthenticatedAction { implicit request =>
    Redirect(routes.Application.index).withNewSession
  }
}
