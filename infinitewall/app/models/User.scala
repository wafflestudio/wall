package models

import org.mindrot.jbcrypt.BCrypt
import play.api.Logger
import utils.Mailer
import GlobalPermission._
import java.util.Date
import java.security.MessageDigest
import scala.util.Try
import ActiveRecord._
import java.util.Calendar
import net.fwbrasil.activate.entity.Entity
import net.fwbrasil.activate.entity.Alias

class User(var email: String,
		var hashedPW: String,
		var picturePath: Option[String] = None,
		var walls: List[Wall] = List(),
		var permission: String = "Normal",

		var ssid: Option[String] = None,
		var provider: Option[String] = None,
		var firstName: Option[String] = None,
		var lastName: Option[String] = None) extends Entity {
	def frozen = transactional {
		User.Frozen(id, email, permission, picturePath, ssid, provider, firstName, lastName)
	}
}

object User extends ActiveRecord[User] {

	case class Frozen(id: String, val email: String, val permission: String, val picturePath: Option[String], val ssid: Option[String], provider: Option[String], firstName: Option[String], lastName: Option[String])

	def getPictureUrl(id: String) = transactional {
		findById(id).get.picturePath.getOrElse(getGravatar(id)).replaceFirst("public/", "/assets/")
	}

	def getPictureOrGravatarUrl(id: String) = {
		val url = getPictureUrl(id)

		if (url.startsWith("http://") || url.startsWith("https://"))
			url
		else
			helpers.infiniteWall.encodeURIComponent("/upload/" + url)
	}

	def getGravatar(id: String) = transactional {
		getGravatarByEmail(Some(findById(id).get.frozen.email))
	}

	def getGravatarByEmail(email: Option[String]) = {
		email match {
			case Some(email) => {
				val md5 = MessageDigest.getInstance("MD5")
				val hash = md5.digest(email.getBytes).map("%02x".format(_)).mkString
				//"http://www.gravatar.com/avatar/" + hash + "?d=http%3A%2F%2Fdeity.mintengine.com%2Fssk.png&s=65"
				"http://www.gravatar.com/avatar/" + hash + "?s=65"
			}
			case _ => "http://zoo.snu.ac/animal_pics/zoo-theme.jpg"
		}
	}

	def findByEmail(email: String) = transactional {
		(select[User] where (_.email :== email))
			.headOption
	}

	def findByEmailAndProvider(email: String, provider: String) = transactional {
		(select[User] where (_.email :== email, _.provider :== provider))
			.headOption
	}

	override def findById(id: String) = transactional {
		(select[User] where (user => (user.id :== id) :|| (user.ssid :== id) :|| (user.email :== id)))
			.headOption
	}

	def update(id: String, firstName: String, lastName: String) {
		transactional {
			findById(id).map { user =>
				user.firstName = Some(firstName)
				user.lastName = Some(lastName)
			}
		}
	}

	private def tenMinutesAgo() = {
		import java.util.Calendar
		import java.text.SimpleDateFormat
		val now = Calendar.getInstance()
		now.add(Calendar.MINUTE, 10)

		now
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

		val groupwalls = query {
			// my shared wall + group's wall
			(user: User, wall: Wall, group: Group, uig: UserInGroup, wig: WallInGroup) =>
				where((user.id :== id) :&&
					(wall :== wig.wall) :&& (wig.group :== group) :&&
					((uig.user :== user) :&& (uig.group :== wig.group))) select (wall)
		}

		groupwalls
	}

	def listNonSharedWalls(id: String) = transactional {
		val sharedWalls = listSharedWalls(id)
		val ownWalls = Wall.findAllOwnedByUserId(id)
		ownWalls.filterNot(sharedWalls.contains)
	}

	def create(id: String, provider: String, firstName: String, lastName: String, email: String, hashedPW: String) {
		transactional {
			new User(email, hashedPW, None, List(), "Normal", Some(id), Some(provider), Some(firstName), Some(lastName)).frozen
		}
	}

	def update(id: String, provider: String, firstName: String, lastName: String, email: String, hashedPW: String) {
		transactional {
			findByEmail(email).map { user =>
				user.ssid = Some(id)
				user.provider = Some(provider)
				user.firstName = Some(firstName)
				user.lastName = Some(lastName)
				user.email = email
				user.hashedPW = hashedPW
			}
		}
	}
}
