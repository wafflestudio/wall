package controllers

import play.api.mvc.Controller
import play.api.mvc.Action
import play.api.mvc.WebSocket
import play.api.mvc.Result
import play.api.libs.json._
import play.api.libs.json.DefaultWrites
import play.api.Logger
import chat._
import play.api.libs.iteratee._
import play.api.libs.concurrent.Akka
import play.api.libs.concurrent.Promise


object Chat extends Controller with Login {

	def chat() = 
		WebSocket.async[JsValue] { request =>
			
			request.session.get("current_user_id") match {
				case Some(id) =>
					ChatSystem.establish(id.toLong)		
				case None =>
					val consumer = Done[JsValue,Unit]((),Input.EOF)
					val producer = Enumerator[JsValue](JsObject(Seq("error" -> JsString("Unauthorized")))).andThen(Enumerator.enumInput(Input.EOF))
					
					Promise.pure(consumer, producer)
			}
		}
	
}
