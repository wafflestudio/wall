package controllers

import play.api._
import mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.data.validation.Constraints._
import play.api.Play.current
import models._
import views._
import helpers._


case class AccountData(val nickname:String)

object Account extends Controller with Auth with Login with SignUp{

  val accountForm = Form {

    mapping(
      "Nickname" -> text
    ) {
      (nickname) =>
        AccountData(nickname)
    } {
      accountData => Some(accountData.nickname)
    }
  }


	
	def index = AuthenticatedAction { implicit request =>
    val user = User.findById(currentUserId).get
    val filledForm = accountForm.fill(AccountData(user.nickname))
		Ok(views.html.account.index(filledForm))
	}

  def signup = Action { implicit request =>
    Ok(views.html.account.signup(signupForm))
  }

  def verify = Action { implicit request =>
  // TODO: UPDATE model
    val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
    val token = params.get("token").getOrElse(Seq("feadbeaffadedead"))

    User.verifyIdentity(token(0))
  // TODO: revise view accordingly
    Ok("")
  }

  def updateUser = AuthenticatedAction { implicit request =>
	  val params = request.body.asFormUrlEncoded.getOrElse[Map[String, Seq[String]]] { Map.empty }
	  val nickname = params.get("Nickname").getOrElse(Seq(""))
	  User.editNickname(currentUserId, nickname(0))
	  Redirect(routes.Account.index)
  }


  def createNewUser = Action { implicit request =>
    signupForm.bindFromRequest.fold(
      formWithErrors => {
        BadRequest(views.html.account.signup(formWithErrors)(loginForm, request)) //.flashing(formWithErrors.get.left.get.toSeq:_*)
      },
      signupData => {
        val user = User.findByEmail(signupData.email).get
        Redirect(routes.Application.index).withSession("current_user" -> user.email, "current_user_id" -> user.id.toString, "current_user_nickname" -> user.nickname)
      }

    )
  }
	
	
}
