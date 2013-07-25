package securesocial.controllers

import play.api.mvc.{RequestHeader, Request}
import play.api.templates.{Html, Txt}
import play.api.{Logger, Plugin, Application}
import securesocial.core.{Identity, SecuredRequest, SocialUser}
import play.api.data.Form
import securesocial.controllers.Registration.RegistrationInfo
import securesocial.controllers.PasswordChange.ChangeInfo

trait TemplatesPlugin extends Plugin {
  override def onStart() {
    Logger.info("[securesocial] loaded templates plugin: %s".format(getClass.getName))
  }

  /**
   * Returns the html for the login page
   * @param request
   * @tparam A
   * @return
   */
  def getLoginPage[A](implicit request: Request[A], form: Form[(String, String)], msg: Option[String] = None): Html

  /**
   * Returns the html for the signup page
   *
   * @param request
   * @tparam A
   * @return
   */
  def getSignUpPage[A](implicit request: Request[A], form: Form[RegistrationInfo], token: String): Html

  /**
   * Returns the html for the start signup page
   *
   * @param request
   * @tparam A
   * @return
   */
  def getStartSignUpPage[A](implicit request: Request[A], form: Form[String]): Html

  /**
   * Returns the html for the reset password page
   *
   * @param request
   * @tparam A
   * @return
   */
  def getResetPasswordPage[A](implicit request: Request[A], form: Form[(String, String)], token: String): Html

  /**
   * Returns the html for the start reset page
   *
   * @param request
   * @tparam A
   * @return
   */
  def getStartResetPasswordPage[A](implicit request: Request[A], form: Form[String]): Html

  /**
   * Returns the html for the change password page
   *
   * @param request
   * @param form
   * @tparam A
   * @return
   */
  def getPasswordChangePage[A](implicit request: SecuredRequest[A], form: Form[ChangeInfo]): Html

  /**
   * Returns the html for the not authorized page
   *
   * @param request
   * @tparam A
   * @return
   */
  def getNotAuthorizedPage[A](implicit request: Request[A]): Html

  /**
   * Returns the email sent when a user starts the sign up process
   *
   * @param token the token used to identify the request
   * @param request the current http request
   * @return a String with the text and/or html body for the email
   */
  def getSignUpEmail(token: String)(implicit request: RequestHeader): (Option[Txt], Option[Html])

  /**
   * Returns the email sent when the user is already registered
   *
   * @param user the user
   * @param request the current request
   * @return a tuple with the text and/or html body for the email
   */
  def getAlreadyRegisteredEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html])

  /**
   * Returns the welcome email sent when the user finished the sign up process
   *
   * @param user the user
   * @param request the current request
   * @return a String with the text and/or html body for the email
   */
  def getWelcomeEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html])

  /**
   * Returns the email sent when a user tries to reset the password but there is no account for
   * that email address in the system
   *
   * @param request the current request
   * @return a String with the text and/or html body for the email
   */
  def getUnknownEmailNotice()(implicit request: RequestHeader): (Option[Txt], Option[Html])

  /**
   * Returns the email sent to the user to reset the password
   *
   * @param user the user
   * @param token the token used to identify the request
   * @param request the current http request
   * @return a String with the text and/or html body for the email
   */
  def getSendPasswordResetEmail(user: Identity, token: String)(implicit request: RequestHeader): (Option[Txt], Option[Html])

  /**
   * Returns the email sent as a confirmation of a password change
   *
   * @param user the user
   * @param request the current http request
   * @return a String with the text and/or html body for the email
   */
  def getPasswordChangedNoticeEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html])

}

/**
 * A trait that defines methods that return the html pages and emails for SecureSocial.
 *
 * If you need to customise the views just create a new plugin
 * and register it instead of DefaultTemplatesPlugin in the play.plugins file of your app.
 *
 * @see DefaultViewsPlugins
 */

class CustomTemplatesPlugin(application: Application) extends TemplatesPlugin 
{
	override def getLoginPage[A](implicit request: Request[A], form: Form[(String, String)],
			msg: Option[String] = None): Html =
	{
		//securesocial.views.html.login(form, msg)
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

	def getResetPasswordPage[A](implicit request: Request[A], form: Form[(String, String)], token: String): Html = {
		//securesocial.views.html.Registration.resetPasswordPage(form, token)
		views.html.custom.securesocial.Registration.resetPasswordPage(form, token)
	}

	def getPasswordChangePage[A](implicit request: SecuredRequest[A], form: Form[ChangeInfo]):Html = {
		//securesocial.views.html.passwordChange(form)
		views.html.custom.securesocial.passwordChange(form)
	}

	def getNotAuthorizedPage[A](implicit request: Request[A]): Html = {
		//securesocial.views.html.notAuthorized()
		securesocial.views.html.notAuthorized()
	}

	def getSignUpEmail(token: String)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.signUpEmail(token)))
		(None, Some(views.html.custom.securesocial.mails.signUpEmail(token)))
	}

	def getAlreadyRegisteredEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.alreadyRegisteredEmail(user)))
		(None, Some(views.html.custom.securesocial.mails.alreadyRegisteredEmail(user)))
	}

	def getWelcomeEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.welcomeEmail(user)))
		(None, Some(views.html.custom.securesocial.mails.welcomeEmail(user)))
	}

	def getUnknownEmailNotice()(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.unknownEmailNotice(request)))
		(None, Some(views.html.custom.securesocial.mails.unknownEmailNotice(request)))
	}

	def getSendPasswordResetEmail(user: Identity, token: String)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.passwordResetEmail(user, token)))
		(None, Some(views.html.custom.securesocial.mails.passwordResetEmail(user, token)))
	}

	def getPasswordChangedNoticeEmail(user: Identity)(implicit request: RequestHeader): (Option[Txt], Option[Html]) = {
		//(None, Some(securesocial.views.html.mails.passwordChangedNotice(user)))
		(None, Some(views.html.custom.securesocial.mails.passwordChangedNotice(user)))
	}
}
