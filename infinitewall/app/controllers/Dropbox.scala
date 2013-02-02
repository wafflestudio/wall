package controllers
// added by Taekmin kim

import play.api._
import play.api.mvc._
import mvc._
import play.api.Play.current
import views._
import helpers._
import com.dropbox.client2.session.WebAuthSession
import com.dropbox.client2.session.Session
import com.dropbox.client2.session.AppKeyPair
import com.dropbox.client2.session.AccessTokenPair
import com.dropbox.client2.session.RequestTokenPair
import com.dropbox.client2.DropboxAPI
import com.dropbox.client2.DropboxAPI.Entry
import com.typesafe.config._
import scala.collection.JavaConversions._
import play.api.libs.json._

object Dropbox extends Controller {

	// get request_token, secret(=oauth_token, secret) and generate access_token
	def authorize() = Action { request =>
		val conf = ConfigFactory.load()
		val dropboxAppKey = conf.getString("dropbox.app_key")
		val dropboxAppSecret = conf.getString("dropbox.app_secret")
		val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)
		val session = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX);

        val info = session.getAuthInfo("http://182.162.143.140:9000/dropbox/callback");
		val requestTokenPair = info.requestTokenPair

		Redirect(info.url).withSession(request.session + ("request_key" -> requestTokenPair.key) +  ("request_secret" -> requestTokenPair.secret))
	}
	
	// get access_token and set access_token to session	
	def callback() = Action { request =>
		val uid: String = request.queryString("uid").first
		val oauthToken: String = request.queryString("oauth_token").first

		val conf = ConfigFactory.load()
		val dropboxAppKey = conf.getString("dropbox.app_key")
		val dropboxAppSecret = conf.getString("dropbox.app_secret")
		val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)
		val session = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX);

		var accessKey: String = request.session.get("access_key").getOrElse("")
		var accessSecret: String = request.session.get("access_secret").getOrElse("")

		var accessTokenPair: AccessTokenPair = null
		if(accessKey == "" && accessSecret == "") {
			val requestKey: String = request.session.get("request_key").getOrElse("")
			val requestSecret: String = request.session.get("request_secret").getOrElse("")

			session.retrieveWebAccessToken(new RequestTokenPair(requestKey, requestSecret))

			accessTokenPair = session.getAccessTokenPair
		} else {
			accessTokenPair = new AccessTokenPair(accessKey, accessSecret)
		}

		Redirect(routes.Account.index).withSession(request.session + ("access_key" -> accessTokenPair.key) + ("access_secret" -> accessTokenPair.secret))
	}

	// /account/info
	def account() = Action { request =>
		val conf = ConfigFactory.load()
		val dropboxAppKey = conf.getString("dropbox.app_key")
		val dropboxAppSecret = conf.getString("dropbox.app_secret")
		val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)

		val accessKey: String = request.session.get("access_key").getOrElse("")
		val accessSecret: String = request.session.get("access_secret").getOrElse("")
		val accessTokenPair: AccessTokenPair = new AccessTokenPair(accessKey, accessSecret)

		val session = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX, accessTokenPair)
        val dropboxApi = new DropboxAPI(session)
		val account = dropboxApi.accountInfo()

		Ok("Name: " + account.displayName)
	}
	
	// /metadata
	def metadata() = Action { request =>
		val conf = ConfigFactory.load()
		val dropboxAppKey = conf.getString("dropbox.app_key")
		val dropboxAppSecret = conf.getString("dropbox.app_secret")
		val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)

		val accessKey: String = request.session.get("access_key").getOrElse("")
		val accessSecret: String = request.session.get("access_secret").getOrElse("")
		val accessTokenPair: AccessTokenPair = new AccessTokenPair(accessKey, accessSecret)

		val session = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX, accessTokenPair)
        val dropboxApi = new DropboxAPI(session)

		var path: String = request.queryString("path").first

		val entry = dropboxApi.metadata(path, 100, null, true, null)
		//https://github.com/jberkel/sbt-dropbox-plugin/blob/master/src/main/scala/sbtdropbox/DropboxAPI.scala

		var contents: Seq[JsObject] = List()
		entry.contents.toList.map { e =>
			contents = contents :+ JsObject(Seq(
				"size" -> JsString(e.size),
				"hash" -> JsString(e.hash),
				"bytes" -> JsNumber(e.bytes),
				"thumb_exists" -> JsBoolean(e.thumbExists),
				"rev" -> JsString(e.rev),
				"modified" -> JsString(e.modified),
				"path" -> JsString(e.path),
				"is_dir" -> JsBoolean(e.isDir),
				"icon" -> JsString(e.icon),
				"root" -> JsString(e.root),
				"revision" -> JsString(e.rev)
			))
		}

		var entryElement: JsObject = JsObject(Seq(
			"size" -> JsString(entry.size),
			"hash" -> JsString(entry.hash),
			"bytes" -> JsNumber(entry.bytes),
			"thumb_exists" -> JsBoolean(entry.thumbExists),
			"rev" -> JsString(entry.rev),
			"modified" -> JsString(entry.modified),
			"path" -> JsString(entry.path),
			"is_dir" -> JsBoolean(entry.isDir),
			"icon" -> JsString(entry.icon),
			"root" -> JsString(entry.root),
			"contents" -> JsArray(contents),
			"revision" -> JsString(entry.rev)
		   ))

		Ok(entryElement)
	}

	// /files (GET)
	def downloadFiles() = Action { request =>
		val conf = ConfigFactory.load()
		val dropboxAppKey = conf.getString("dropbox.app_key")
		val dropboxAppSecret = conf.getString("dropbox.app_secret")
		val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)

		val accessKey: String = request.session.get("access_key").getOrElse("")
		val accessSecret: String = request.session.get("access_secret").getOrElse("")
		val accessTokenPair: AccessTokenPair = new AccessTokenPair(accessKey, accessSecret)

		val session = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX, accessTokenPair)
        val dropboxApi = new DropboxAPI(session)

		Ok("Success")
	}

	// /files (POST)
	def uploadFiles() = Action { request =>
		val conf = ConfigFactory.load()
		val dropboxAppKey = conf.getString("dropbox.app_key")
		val dropboxAppSecret = conf.getString("dropbox.app_secret")
		val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)

		val accessKey: String = request.session.get("access_key").getOrElse("")
		val accessSecret: String = request.session.get("access_secret").getOrElse("")
		val accessTokenPair: AccessTokenPair = new AccessTokenPair(accessKey, accessSecret)

		val session = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX, accessTokenPair)
        val dropboxApi = new DropboxAPI(session)

		Ok("Success")
	}
}
