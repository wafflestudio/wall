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

case class AccountInfo(firstName: String, lastName: String)

object Account extends Controller with securesocial.core.SecureSocial {
  val userForm:Form[AccountInfo] = Form (
      mapping (
          "firstName" -> nonEmptyText,
          "lastName" -> nonEmptyText
      )(AccountInfo.apply)(AccountInfo.unapply)
  )

  def index = SecuredAction { implicit request =>
	Ok(views.html.account.index(request.user))
  }

  def edit = SecuredAction { implicit request =>
    val accountForm = userForm.fill(AccountInfo(request.user.firstName, request.user.lastName))
	Ok(views.html.account.edit(accountForm, request.user))
  }

  def update = UserAwareAction(parse.multipartFormData) { implicit request =>
    userForm.bindFromRequest.fold(
      formWithErrors => BadRequest,
      user => {
        request.body.file("photo").map { photo =>
          utils.FileSystem.moveTempFile(photo.ref, "public/files", photo.filename)
          User.setPicture(request.user.get.email.getOrElse(""), photo.filename)
        }
        User.update(request.user.get.email.getOrElse(""), user.firstName, user.lastName)
        Redirect(routes.Account.edit())
      }
    )
  }
}
