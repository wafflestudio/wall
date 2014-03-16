package controllers

import com.typesafe.config.ConfigFactory

import helpers._
import models._
import play.api._
import play.api.Play.current
import play.api.data.Forms._
import play.api.data.validation.Constraints._
import play.api.libs.json.JsValue
import play.api.mvc._
import se.digiplant.scalr._

object FileController extends Controller {

	lazy val config = ConfigFactory.load()
	lazy val rootPath = {
		val mode = if (play.Play.isProd) "production" else if (play.Play.isDev) "development" else "test"
		config.getString(s"${mode}.file.rootpath")
	}

	/*
	def upload = Action(parse.multipartFormData) { request =>
		
		var fileList:Seq[JsObject] = List()
		
		request.body.files.map { picture =>
			import java.io.File
			val filename = picture.filename
      val savedFilename = DigestUtils.shaHex(1.toString)

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
	//def thumb(file: String) = ScalrResAssets.at(file, 120, 120, mode = "crop", source="fit_to_width")
	def thumb(file: String, width: Integer, height: Integer) = ScalrAssets.at(rootPath, helpers.infiniteWall.decodeURIComponent(file), width, height, "fit_to_width")

	def serve(filePath: String) = Action {
		Logger.info("serving file : " + filePath)
		val file = new java.io.File(rootPath + "/" + helpers.infiniteWall.decodeURIComponent(filePath))
		if (file.exists)
			Ok.sendFile(content = file, inline = true)
		else
			NotFound("File not found:" + filePath + "(" + helpers.infiniteWall.decodeURIComponent(filePath) + ")")
	}

	def serveUserProfilePicture(userId: String) = Action {
		val url = User.getPictureOrGravatarUrl(userId)

		Redirect(url)
	}

}
