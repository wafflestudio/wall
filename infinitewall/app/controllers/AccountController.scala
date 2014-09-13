package controllers

import models.User
import play.api.data.Form
import play.api.data.Forms.{ mapping, nonEmptyText }

case class AccountParam(firstName: String, lastName: String)

object AccountController extends Controller with SecureSocial {

	val userForm: Form[AccountParam] = Form {
		mapping(
			"firstName" -> nonEmptyText,
			"lastName" -> nonEmptyText)(AccountParam.apply)(AccountParam.unapply)
	}

	def index = securedAction { implicit request =>
		Ok(views.html.account.index(request.user))
	}

	def edit = securedAction { implicit request =>
		val accountForm = userForm.fill(AccountParam(request.user.firstName, request.user.lastName))
		Ok(views.html.account.edit(accountForm, request.user))
	}

	def update = securedAction(parse.multipartFormData) { implicit request =>

		val currentUser = request.user

		userForm.bindFromRequest.fold(
			formWithErrors => BadRequest,
			user => {
				request.body.file("photo").map { photo =>
					utils.FileSystem.moveTempFile(photo.ref, "public/files", photo.filename)
					User.setPicture(currentUser.email.getOrElse(""), photo.filename)
				}
				User.update(id = currentUser.email.getOrElse(""), firstName = user.firstName, lastName = user.lastName)
				Redirect(routes.AccountController.edit())
			})

	}
}
