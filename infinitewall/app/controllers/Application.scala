package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.data.validation.Constraints._
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.libs.json.JsValue
import play.api.libs.json.Json
import models._
import views._
import helpers._

case class LoginData(val email: String, val password: String)
case class SignUpData(val email: String, val password: String, val nickname:String)
case class CurrentUser(val userId: Long, val email: String)


trait Auth {
	self: Controller =>

	def currentUser(implicit request: Request[AnyContent]): String = {
		request.session.get("current_user").getOrElse("default")
	}

	def currentUserId(implicit request: Request[AnyContent]): Long = {
		request.session.get("current_user_id").getOrElse("-1").toLong
	}

	def currentUserNickname(implicit request: Request[AnyContent]): String = {
    // TODO: cache
		User.findById(currentUserId).get.nickname
	}

  def currentUserPicturePath(implicit request: Request[AnyContent]) = {
    User.findById(currentUserId).get.picturePath.getOrElse(User.getGravatar(currentUser)).replaceFirst("public/","/assets/")
  }

	def AuthenticatedAction(f: Request[AnyContent] => Result): Action[AnyContent] = 
		Action { implicit request =>
			if (request.session.get("current_user").isDefined)
				f(request)
			else  {
				Logger.info("unauthorized access:" + request.uri)
				Forbidden("You are not authorized to access this url")
			}
		}

  def AuthenticatedAction[A](bodyParser: BodyParser[A])(f: Request[A] => Result): Action[A] =
    Action(bodyParser) { implicit request =>
      if (request.session.get("current_user").isDefined)
        f(request)
      else  {
        Logger.info("unauthorized access:" + request.uri)
        Forbidden("You are not authorized to access this url")
      }
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
        val user = User.findByEmail(loginData.email).get
        Redirect(routes.Application.index).withSession("current_user" -> user.email, "current_user_id" -> user.id.toString)
      }
    )

  }

	def logout = AuthenticatedAction { implicit request =>
		Redirect(routes.Application.index).withNewSession
	}
}
