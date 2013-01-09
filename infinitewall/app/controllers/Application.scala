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

	def AuthenticatedAction(f: Request[AnyContent] => Result): Action[AnyContent] = 
		Action { implicit request =>
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

trait SignUp {

	val signupForm = Form {
		val user2Tuple = (user: User) => (user.email, "", "")

		mapping("Email" -> email,
			"Password" -> tuple(
				"main" -> text(minLength = 8),
				"confirm" -> text
			).verifying("password fields must be identical", t => t._1 == t._2),
			"Nickname" -> text
		) {
				(email, passwords, nickname) =>
					SignUpData(email, passwords._1, nickname)
			} {
				signupData => Some(signupData.email, ("", ""), "")
			}.verifying("The email address is already taken", signup => User.signup(signup.email, signup.password).isDefined)
	}
}

object Application extends Controller with Login with SignUp {

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

	def logout = AuthenticatedAction { implicit request =>
		Redirect(routes.Application.index).withNewSession
	}

	def signup = Action { implicit request =>
		Ok(views.html.signup(signupForm))
	}

	def authenticate = Action { implicit request =>
		loginForm.bindFromRequest.fold(
			formWithErrors => {
				Redirect(routes.Application.index).flashing("error" -> "Bad username or password")
			},
			loginData => {
				val user = User.findByEmail(loginData.email).get
				Redirect(routes.Application.index).withSession("current_user" -> user.email, "current_user_id" -> user.id.toString, "current_user_nickname" -> "newNickname")
			}
		)

	}

	def createNewUser = Action { implicit request =>

		signupForm.bindFromRequest.fold(
			formWithErrors => {
				BadRequest(views.html.signup(formWithErrors)(loginForm, request)) //.flashing(formWithErrors.get.left.get.toSeq:_*)
			},
			signupData => {
				val user = User.findByEmail(signupData.email).get
				Redirect(routes.Application.index).withSession("current_user" -> user.email, "current_user_id" -> user.id.toString, "current_user_nickname" -> "newNickname")
			}
				
		)
	}

}
