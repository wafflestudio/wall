package controllers

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

object Dropbox extends Controller {

	def authorize() = Action { request =>
		val conf = ConfigFactory.load()
		val dropboxAppKey = conf.getString("dropbox.app_key")
		val dropboxAppSecret = conf.getString("dropbox.app_secret")
		val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)
		val session = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX);

        val info = session.getAuthInfo("http://182.162.143.140:9000/dropbox/callback");
		val requestTokenPair = info.requestTokenPair

		Redirect(info.url).withSession("request_key" -> requestTokenPair.key, "request_secret" -> requestTokenPair.secret)
	}
	
	def callback() = Action { request =>
		val uid: String = request.queryString.get("uid").toString
		val oauthToken: String = request.queryString.get("oauth_token").toString

		val conf = ConfigFactory.load()
		val dropboxAppKey = conf.getString("dropbox.app_key")
		val dropboxAppSecret = conf.getString("dropbox.app_secret")
		val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)
		val session = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX);

		var accessKey: String = request.session.get("access_key").getOrElse("")
		var accessSecret: String = request.session.get("access_secret").getOrElse("")


		var accessTokenPair: AccessTokenPair = null
		if(accessKey == "") {
			val requestKey: String = request.session.get("request_key").getOrElse("")
			val requestSecret: String = request.session.get("request_secret").getOrElse("")

			session.retrieveWebAccessToken(new RequestTokenPair(requestKey, requestSecret))

			accessTokenPair = session.getAccessTokenPair
		} else {
			accessTokenPair = new AccessTokenPair(accessKey, accessSecret)
		}
		accessKey = accessTokenPair.key
		accessKey = accessTokenPair.secret

		val sourceSession = new WebAuthSession(appKeyPair, Session.AccessType.DROPBOX, accessTokenPair)
        val dropboxApi = new DropboxAPI(sourceSession)
		val account = dropboxApi.accountInfo()

		// reference: https://www.dropbox.com/static/developers/dropbox-java-sdk-1.5-docs/com/dropbox/client2/DropboxAPI.Entry.htm://www.dropbox.com/developers/reference/api#metadata 
		// reference: https://www.dropbox.com/static/developers/dropbox-java-sdk-1.5-docs/com/dropbox/client2/DropboxAPI.Entry.html
		val entry = dropboxApi.metadata("/", 1, null, false, null);

		Ok("Name: " + account.displayName).withSession("access_key" -> accessTokenPair.key, "access_secret" -> accessTokenPair.secret)
	}
}
