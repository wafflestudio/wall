package controllers

import play.api._
import play.api.mvc._

object Application extends Controller {
  
  def index = Action {
    Ok(views.html.index())
  }
  def about = Action {
    Ok(views.html.about())
  }
  def contact = Action {
    Ok(views.html.contact())
  }
  def hello(name:String) = Action {
    Ok("Hello " + name)
  }
  
}
