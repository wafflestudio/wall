package models
import org.mindrot.jbcrypt.BCrypt
import play.api.Logger
import utils.Mailer
import GlobalPermission._
//import play.api.Play.current
import java.util.Date
import java.security.MessageDigest
import scala.util.Try
import ActiveRecord._
import java.util.Calendar
import net.fwbrasil.activate.entity.Entity
import net.fwbrasil.activate.entity.Alias



class User(var email: String, 
  var hashedPW: String, 
  var nickname: String, 
  var picturePath: Option[String] = None, 
  var walls:List[Wall] = List(),
  var verified: Boolean = false, 
  var verificationToken:Option[String] = None, 
  var verificationTokenCreated:Option[Calendar] = None,
  var permission: String = "Normal" ) extends Entity
{
  def frozen = transactional {
    User.Frozen(id, email, permission, nickname, picturePath, verified)
  }
}

object User extends ActiveRecord[User] {

  case class Frozen(id: String, val email: String, val permission: String,
  val nickname: String, val picturePath: Option[String], val verified: Boolean)
  
  def getPictureUrl(userId: String) = transactional {
    findById(userId).get.picturePath.getOrElse(getGravatar(userId)).replaceFirst("public/", "/assets/")
  }
  
  def getPictureOrGravatarUrl(userId: String) = {
    val url = getPictureUrl(userId)
    
    if (url.startsWith("http://") || url.startsWith("https://"))
      url
    else
      helpers.infiniteWall.encodeURIComponent("/upload/" + url)
  }

  def getGravatar(userId: String) = transactional {    
    getGravatarByEmail(findById(userId).get.frozen.email)
  }

  def getGravatarByEmail(email: String) = {
    val md5 = MessageDigest.getInstance("MD5")
    val hash = md5.digest(email.getBytes).map("%02x".format(_)).mkString
    "http://www.gravatar.com/avatar/" + hash + "?d=http%3A%2F%2Fdeity.mintengine.com%2Fssk.png&s=65"
  }

  def findByEmail(email: String) = transactional {
    (select[User] where(_.email :== email))
    .headOption
  }
  

  def authenticate(email: String, password: String): Option[Frozen] = transactional(required) {
    findByEmail(email).flatMap { u =>
      if (BCrypt.checkpw(password, u.hashedPW)) {
        Some(u.frozen)
      }
      else
        None
    }
  }


  def signup(email: String, password: String, nickname: String, picturePath: String = ""): Option[Frozen] = transactional {
    Try {
      transactional {
        new User(email, hashedPW(password), nickname, Some(picturePath)).frozen
      }
    }.map { user =>
      Mailer.sendVerification(user)
      user
    }.toOption
  }

  private def tenMinutesAgo() = {
    import java.util.Calendar
    import java.text.SimpleDateFormat
    val now = Calendar.getInstance()
    now.add(Calendar.MINUTE, 10)
   
    now
  }

  def verifyIdentity(token: String) {
    val cal = tenMinutesAgo
    transactional {
      val foundUser = select[User] where(e => (e.verificationToken :== token) :&& (e.verificationTokenCreated :>= cal))
      foundUser.map(_.verified = true)
    }
  }

  def editNickname(id: String, nickname: String) {
    transactional {
      findById(id).map(_.nickname = nickname)
    }
  }

  def setPicture(id: String, path: String) {
    transactional {
      findById(id).map(_.picturePath = Some(path))
    }
  }

  def listGroups(id: String) = transactional {
    Group.findAllOwnedByUserId(id)
  }
  

  def listSharedWalls(id: String) = transactional {
    query {
      (user:User, wall:Wall, group:Group, uig:UserInGroup, wig: WallInGroup) => 
        where((wall :== wig.wall) :&& (((uig.user :== user) :&& (uig.group :== wig.group)) :|| (group.owner :== user))) select(wall)
    }
  }
  

  def listNonSharedWalls(id: String) = transactional {
    val sharedWalls = listSharedWalls(id)
    val ownWalls = Wall.findAllOwnedByUserId(id)
    ownWalls.filterNot(sharedWalls.contains)
  }
  

  def hashedPW(pw: String) = BCrypt.hashpw(pw, BCrypt.gensalt(12))
}
