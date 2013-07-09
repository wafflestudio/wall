package controllers
// added by Taekmin kim

import play.api._
import play.api.mvc._
import mvc._
import play.api.Play.current
import views._
import helpers._
import com.dropbox.client2.session.WebAuthSession
import com.dropbox.client2.session.{Session => DropboxSession}
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
    val session = new WebAuthSession(appKeyPair, DropboxSession.AccessType.DROPBOX);

    val info = session.getAuthInfo("http://" + request.host + "/dropbox/callback");
    val requestTokenPair = info.requestTokenPair

    Redirect(info.url).withSession(request.session + ("request_key" -> requestTokenPair.key) + ("request_secret" -> requestTokenPair.secret))
  }

  // get access_token and set access_token to session	
  def callback() = Action { request =>
    val uid: String = request.queryString("uid").head
    val oauthToken: String = request.queryString("oauth_token").head

    val conf = ConfigFactory.load()
    val dropboxAppKey = conf.getString("dropbox.app_key")
    val dropboxAppSecret = conf.getString("dropbox.app_secret")
    val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)
    val session = new WebAuthSession(appKeyPair, DropboxSession.AccessType.DROPBOX);

    var accessKey: String = request.session.get("access_key").getOrElse("")
    var accessSecret: String = request.session.get("access_secret").getOrElse("")

    var accessTokenPair: AccessTokenPair = null
    if (accessKey == "" && accessSecret == "") {
      val requestKey: String = request.session.get("request_key").getOrElse("")
      val requestSecret: String = request.session.get("request_secret").getOrElse("")

      session.retrieveWebAccessToken(new RequestTokenPair(requestKey, requestSecret))

      accessTokenPair = session.getAccessTokenPair
    }
    else {
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

    val session = new WebAuthSession(appKeyPair, DropboxSession.AccessType.DROPBOX, accessTokenPair)
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

    val session = new WebAuthSession(appKeyPair, DropboxSession.AccessType.DROPBOX, accessTokenPair)
    val dropboxApi = new DropboxAPI(session)

    var path: String = request.queryString("path").head

    val entry = dropboxApi.metadata(path, 100, null, true, null)
    //https://github.com/jberkel/sbt-dropbox-plugin/blob/master/src/main/scala/sbtdropbox/DropboxAPI.scala

    var contents: Seq[JsObject] = List()
    entry.contents.toList.map { e =>
      contents = contents :+ Json.obj(
        "size" -> e.size,
        "hash" -> e.hash,
        "bytes" -> e.bytes,
        "thumb_exists" -> e.thumbExists,
        "rev" -> e.rev,
        "modified" -> e.modified,
        "path" -> e.path,
        "is_dir" -> e.isDir,
        "icon" -> e.icon,
        "root" -> e.root,
        "revision" -> e.rev
      )
    }

    var entryElement: JsObject = Json.obj(
      "size" -> entry.size,
      "hash" -> entry.hash,
      "bytes" -> entry.bytes,
      "thumb_exists" -> entry.thumbExists,
      "rev" -> entry.rev,
      "modified" -> entry.modified,
      "path" -> entry.path,
      "is_dir" -> entry.isDir,
      "icon" -> entry.icon,
      "root" -> entry.root,
      "contents" -> Json.arr(contents),
      "revision" -> entry.rev
    )

    Ok(entryElement)
  }

  def shares() = Action { request =>
    val conf = ConfigFactory.load()
    val dropboxAppKey = conf.getString("dropbox.app_key")
    val dropboxAppSecret = conf.getString("dropbox.app_secret")
    val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)

    val accessKey: String = request.session.get("access_key").getOrElse("")
    val accessSecret: String = request.session.get("access_secret").getOrElse("")
    val accessTokenPair: AccessTokenPair = new AccessTokenPair(accessKey, accessSecret)

    val session = new WebAuthSession(appKeyPair, DropboxSession.AccessType.DROPBOX, accessTokenPair)
    val dropboxApi = new DropboxAPI(session)

    var path: String = request.queryString("path").head

    val link = dropboxApi.share(path)
    //https://github.com/jberkel/sbt-dropbox-plugin/blob/master/src/main/scala/sbtdropbox/DropboxAPI.scala

    var json = Json.obj(
      "path" -> path,
      "url" -> link.url,
      "expires" -> link.expires.toString
    )

    Ok(json)
  }

  def media() = Action { request =>
    val conf = ConfigFactory.load()
    val dropboxAppKey = conf.getString("dropbox.app_key")
    val dropboxAppSecret = conf.getString("dropbox.app_secret")
    val appKeyPair = new AppKeyPair(dropboxAppKey, dropboxAppSecret)

    val accessKey: String = request.session.get("access_key").getOrElse("")
    val accessSecret: String = request.session.get("access_secret").getOrElse("")
    val accessTokenPair: AccessTokenPair = new AccessTokenPair(accessKey, accessSecret)

    val session = new WebAuthSession(appKeyPair, DropboxSession.AccessType.DROPBOX, accessTokenPair)
    val dropboxApi = new DropboxAPI(session)

    var path: String = request.queryString("path").head

    val link = dropboxApi.media(path, false)
    //https://github.com/jberkel/sbt-dropbox-plugin/blob/master/src/main/scala/sbtdropbox/DropboxAPI.scala

    var json = Json.obj(
      "path" -> path,
      "url" -> link.url,
      "expires" -> link.expires.toString
    )

    Ok(json)
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

    val session = new WebAuthSession(appKeyPair, DropboxSession.AccessType.DROPBOX, accessTokenPair)
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

    val session = new WebAuthSession(appKeyPair, DropboxSession.AccessType.DROPBOX, accessTokenPair)
    val dropboxApi = new DropboxAPI(session)

    Ok("Success")
  }
}
