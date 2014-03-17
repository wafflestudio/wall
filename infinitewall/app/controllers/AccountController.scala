package controllers

import models.User
import play.api.data.Form
import play.api.data.Forms.{ mapping, nonEmptyText }

case class AccountParam(firstName: String, lastName: String)

object AccountController extends Controller with securesocial.core.SecureSocial {
	val userForm: Form[AccountParam] = Form {
		mapping(
			"firstName" -> nonEmptyText,
			"lastName" -> nonEmptyText)(AccountParam.apply)(AccountParam.unapply)
	}

	def index = SecuredAction { implicit request =>
		Ok(views.html.account.index(request.user))
	}

	def edit = SecuredAction { implicit request =>
		val accountForm = userForm.fill(AccountParam(request.user.firstName, request.user.lastName))
		Ok(views.html.account.edit(accountForm, request.user))
	}

	def update = UserAwareAction(parse.multipartFormData) { implicit request =>
		request.user match {
			case Some(currentUser) => {
				userForm.bindFromRequest.fold(
					formWithErrors => BadRequest,
					user => {
						request.body.file("photo").map { photo =>
							utils.FileSystem.moveTempFile(photo.ref, "public/files", photo.filename)
							User.setPicture(currentUser.email.getOrElse(""), photo.filename)
						}
						User.update(currentUser.email.getOrElse(""), user.firstName, user.lastName)
						Redirect(routes.AccountController.edit())
					})
			}
			case _ => Unauthorized
		}
	}
}
