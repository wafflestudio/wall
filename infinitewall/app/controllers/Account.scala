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

case class AccountData(val nickname: String)

object Account extends Controller with Auth with Login {

  val signupForm = Form {
    val user2Tuple = (user: User) => (user.email, "", "")

    mapping("Email" -> email,
      "Password" -> tuple(
        "main" -> text(minLength = 8, maxLength = 80),
        "confirm" -> text
      ).verifying("password fields must be identical", t => t._1 == t._2),
      "Nickname" -> text(maxLength = 255)
    ) {
        (email, passwords, nickname) =>
          SignUpData(email, passwords._1, nickname)
      } {
        signupData => Some(signupData.email, ("", ""), "")
      }.verifying("The email address is already taken", signup => 
        transactional {
          User.signup(signup.email, signup.password, signup.nickname).isDefined 
        })
  }

  // TODO: check usage
  val accountForm = Form {
    mapping(
      "Nickname" -> text(maxLength = 255)
    ) {
        (nickname) =>
          AccountData(nickname)
      } {
        accountData => Some(accountData.nickname)
      }
  }

  def index = AuthenticatedAction { implicit request =>
    val user = 
      transactional { User.findById(currentUserId).map(_.frozen).get }
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

    val user = User.findById(currentUserId).map(_.frozen).get
    request.body.asMultipartFormData.map { md =>
      md.file("ProfilePicture").map { file =>
        User.setPicture(user.id, placeUserFile(user, file))
      }
      val params = md.asFormUrlEncoded
      User.editNickname(user.id, params.get("Nickname").get.head)
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
        val user = User.findByEmail(signupData.email).map(_.frozen).get
        request.body.asMultipartFormData.map { md =>
          md.file("files").map { file =>
            User.setPicture(user.id, placeUserFile(user, file))
          }
        }
        Redirect(routes.Application.index).withSession("session_token" -> ActiveRecord.sessionToken,"current_user" -> user.email, "current_user_id" -> user.id.toString)

      }
    )
  }

  private def placeUserFile(user: User.Frozen, file: MultipartFormData.FilePart[TemporaryFile]) = {
    val encodedFolderName = user.id
    val encodedFileName = file.filename
    val dir = new java.io.File("public/files/" + encodedFolderName).mkdirs()

    if(encodedFileName.isEmpty)
      "Error"
    else {
      val path = encodedFolderName + "/" + encodedFileName
      val newFile = new java.io.File("public/files/" + path)
      file.ref.moveTo(newFile, true)
      path
    }
  }
}
