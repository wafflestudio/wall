package controllers

import play.api._
import libs.Files.TemporaryFile
import mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.data.validation.Constraints._
import play.api.Play.current
import models._
import views._
import helpers._
import java.io.File


case class AccountData(val nickname:String)

object Account extends Controller with Auth with Login {

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
    }.verifying("The email address is already taken", signup => User.signup(signup.email, signup.password, signup.nickname).isDefined)
  }

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


  def update = AuthenticatedAction { implicit request =>

    val user = User.findById(currentUserId).get
    request.body.asMultipartFormData.map {  md =>
      md.file("ProfilePicture").map { file =>
        val encodedFolderName = java.net.URLEncoder.encode(user.email, "UTF-8")
        val encodedFileName = java.net.URLEncoder.encode(file.filename, "UTF-8")
        val dir = new File("public/files/" + encodedFolderName)
        dir.mkdirs()
        val path = "public/files/"+ encodedFolderName + "/" + encodedFileName
        val newFile = new File(path)
        file.ref.moveTo(newFile, true)
        User.setPicture(user.id.get, path)
      }
      val params = md.asFormUrlEncoded
      User.update(user.id.get, params.get("Nickname").get(0))
    }

    Redirect(routes.Account.index).flashing("msg" -> "Successfully updated")
  }


  def createNewUser = Action { implicit request =>
    signupForm.bindFromRequest.fold(
      formWithErrors => {
        // TODO: fill previous form
        BadRequest(views.html.account.signup(formWithErrors))
      },
      signupData => {
        val user = User.findByEmail(signupData.email).get
        request.body.asMultipartFormData.map {  md =>
          md.file("files").map { file =>
            val encodedFolderName = java.net.URLEncoder.encode(user.email, "UTF-8")
            val encodedFileName = java.net.URLEncoder.encode(file.filename, "UTF-8")
            val dir = new File("public/files/" + encodedFolderName)
            dir.mkdirs()
            val path = "public/files/"+ encodedFolderName + "/" + encodedFileName
            val newFile = new File(path)
            file.ref.moveTo(newFile, true)
            User.setPicture(user.id.get, path)
          }
        }
        Redirect(routes.Application.index).withSession("current_user" -> user.email, "current_user_id" -> user.id.toString, "current_user_nickname" -> "newNickname")

      }
    )
  }
	
	
}
