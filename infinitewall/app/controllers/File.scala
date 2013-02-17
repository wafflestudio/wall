package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.data.validation.Constraints._
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.libs.json.JsValue
import play.api.libs.json.Json
import models._
import views._
import helpers._
import play.api.libs.json._
import org.apache.commons.codec.digest.DigestUtils

object File extends Controller {

  /*
	def upload = Action(parse.multipartFormData) { request =>
		
		var fileList:Seq[JsObject] = List()
		
		request.body.files.map { picture =>
			import java.io.File
			val filename = picture.filename
      val savedFilename = DigestUtils.sha1Hex(1.toString)

			val contentType = picture.contentType
			val newFile = new File("public/files/sheet/" + picture.filename)
			picture.ref.moveTo(newFile, true)
			
			fileList = fileList :+ JsObject(Seq(
					"name" -> JsString(filename),
					"size" -> JsNumber(newFile.length),
					"url" -> JsString("/upload/" + picture.filename),
					"delete_url" -> JsString("/file"),
					"delete_type" -> JsString("delete")
			))
		}
		Ok(JsArray(fileList))
	}

  def info = Action {
		Ok("")
	}

	def replace = Action {
		Ok("")
	}

	def delete = Action {
		Ok("")
	}
	*/

  def serve(filePath: String) = Action {
    Logger.info("serving file : " + filePath)
    Ok.sendFile(content = new java.io.File("public/files/" + filePath), inline=true)
  }


	



}