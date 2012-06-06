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
import org.squeryl.PrimitiveTypeMode._

case class LoginData(val username: String, val password: String)
case class SignUpData(val username: String, val email: String, val password: String)

trait Login {
	self: Controller =>

	def AuthenticatedAction(f: Request[AnyContent] => Result): Action[AnyContent] = {
		Action { request =>
			if (request.session.get("current_user").isDefined)
				f(request)
			else
				Forbidden
		}
	}

	implicit val loginForm = Form {
		mapping("username" -> nonEmptyText, "password" -> text)(LoginData.apply)(LoginData.unapply)
			.verifying("Invalid username or password",
				loginData => User.authenticate(loginData.username, loginData.password).isDefined
			)
	}
}

trait SignUp {

	val signupForm = Form {
		val user2Tuple = (user: User) => (user.username, "", "")

		mapping("Username" -> nonEmptyText,
			"email" -> email,
			"Password" -> tuple(
				"main" -> text(minLength = 6),
				"confirm" -> text
			).verifying("password fields must be identical", t => t._1 == t._2)
		) {
				(username, email, passwords) =>
					SignUpData(username, email, passwords._1)
		} {
				signupData => Some(signupData.username, signupData.email, ("", ""))
		}.verifying("Username is already taken", signup => User.signup(signup.username, signup.email, signup.password).isDefined)
	}
}

object Application extends Controller with Login with SignUp {

	def index = Action { implicit request =>
		Ok(views.html.index())
	}

	def about = Action {
		Ok(views.html.about())
	}
	def contact = Action {
		Ok(views.html.contact())
	}
	def hello(name: String) = Action {
		Ok("Hello " + name)
	}

	def logout = AuthenticatedAction { implicit request =>
		Redirect(routes.Application.index).withNewSession
	}

	def signup = Action { implicit request =>
		Ok(views.html.signup(signupForm) + "")
	}

	def authenticate = Action { implicit request =>
		loginForm.bindFromRequest.fold(
			formWithErrors => {
				//Redirect(routes.MainController.index).flashing("error" -> "Bad login") 
				BadRequest(views.html.index()(formWithErrors, request))
			},
			user => Redirect(routes.Application.index).withSession("current_user" -> user.username)
		)
	}

	def createNewUser = Action { implicit request =>

		signupForm.bindFromRequest.fold(
			formWithErrors => {
				BadRequest(views.html.signup(formWithErrors)(loginForm, request)) //.flashing(formWithErrors.get.left.get.toSeq:_*)
			},
			newUser => Redirect(routes.Application.index)
		)
	}

}

