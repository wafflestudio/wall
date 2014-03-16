package securesocial.controllers

import play.api.{ Application, Logger }
import play.api.data.Form
import play.api.mvc.{ Request, RequestHeader }
import play.api.templates._
import securesocial.controllers.PasswordChange.ChangeInfo
import securesocial.controllers.Registration.RegistrationInfo
import securesocial.core.{ Identity, SecuredRequest }

class CustomTemplatesPlugin(application: Application) extends DefaultTemplatesPlugin(application) {

	def logLanguage(implicit lang: play.api.i18n.Lang) = Logger.info(lang.toString)

	override def getLoginPage[A](implicit request: Request[A], form: Form[(String, String)],
		msg: Option[String] = None): Html =
		{
			//securesocial.views.html.login(form, msg)
			logLanguage
			views.html.custom.securesocial.login(form, msg)
		}
	override def getSignUpPage[A](implicit request: Request[A], form: Form[RegistrationInfo], token: String): Html = {
		//securesocial.views.html.Registration.signUp(form, token)
		views.html.custom.securesocial.Registration.signUp(form, token)
	}
	override def getStartSignUpPage[A](implicit request: Request[A], form: Form[String]): Html = {
		//securesocial.views.html.Registration.startSignUp(form)
		views.html.custom.securesocial.Registration.startSignUp(form)
	}

	override def getStartResetPasswordPage[A](implicit request: Request[A], form: Form[String]): Html = {
		//securesocial.views.html.Registration.startResetPassword(form)
		views.html.custom.securesocial.Registration.startResetPassword(form)
	}

	override def getResetPasswordPage[A](implicit request: Request[A], form: Form[(String, String)], token: String): Html = {
		//securesocial.views.html.Registration.resetPasswordPage(form, token)
		views.html.custom.securesocial.Registration.resetPasswordPage(form, token)
	}

	override def getPasswordChangePage[A](implicit request: SecuredRequest[A], form: Form[ChangeInfo]): Html = {
		//securesocial.views.html.passwordChange(form)
		views.html.custom.securesocial.passwordChange(form)
	}

	override def getNotAuthorizedPage[A](implicit request: Request[A]): Html = {
		//securesocial.views.html.notAuthorized()
		securesocial.views.html.notAuthorized()
	}

	override def getSignUpEmail(token: String)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.signUpEmail(token)))
		(None, Some(views.html.custom.securesocial.mails.signUpEmail(token)))
	}

	override def getAlreadyRegisteredEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.alreadyRegisteredEmail(user)))
		(None, Some(views.html.custom.securesocial.mails.alreadyRegisteredEmail(user)))
	}

	override def getWelcomeEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.welcomeEmail(user)))
		(None, Some(views.html.custom.securesocial.mails.welcomeEmail(user)))
	}

	override def getUnknownEmailNotice()(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.unknownEmailNotice(request)))
		(None, Some(views.html.custom.securesocial.mails.unknownEmailNotice(request)))
	}

	override def getSendPasswordResetEmail(user: Identity, token: String)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.passwordResetEmail(user, token)))
		(None, Some(views.html.custom.securesocial.mails.passwordResetEmail(user, token)))
	}

	override def getPasswordChangedNoticeEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.passwordChangedNotice(user)))
		(None, Some(views.html.custom.securesocial.mails.passwordChangedNotice(user)))
	}
}
