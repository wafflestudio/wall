package controllers

import play.api.mvc.Action

object Sandbox extends Controller {

	// TODO: add filter for production mode
	def editor = Action {
		Ok(views.html.sandbox.editor())
	}
}