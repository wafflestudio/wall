package models

import java.security.MessageDigest
import java.util.Calendar

import ActiveRecord._
import GlobalPermission._
import net.fwbrasil.activate.entity.Entity

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
		User.Frozen(id, email, hashedPW, permission, picturePath, ssid, provider, firstName, lastName)
	}
}

object User extends ActiveRecord[User] {

	case class Frozen(id: String, email: String, hashedPW: String, permission: String, picturePath: Option[String], ssid: Option[String], provider: Option[String], firstName: Option[String], lastName: Option[String])

	def getPictureUrl(id: String) = transactional {
		find(id).get.picturePath.getOrElse(getGravatar(id)).replaceFirst("public/", "/assets/")
	}

	def getPictureOrGravatarUrl(id: String) = {
		val url = getPictureUrl(id)

		if (url.startsWith("http://") || url.startsWith("https://"))
			url
		else
			helpers.infiniteWall.encodeURIComponent("/upload/" + url)
	}

	def getGravatar(id: String) = transactional {
		getGravatarByEmail(Some(find(id).get.frozen.email))
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
		(select[User] where (user => (user.email :== email) :&& (user.provider :== provider)))
			.headOption
	}

	override def find(id: String) = transactional {
		(select[User] where (user => (user.id :== id) :|| (user.ssid :== id) :|| (user.email :== id)))
			.headOption
	}

	def update(id: String, firstName: String, lastName: String) {
		transactional {
			find(id).map { user =>
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
			find(id).map(_.picturePath = Some(path))
		}
	}

	def getOwnedGroups(id: String) = transactional {
		Group.findAllOwnedByUser(id)
	}

	def getIncludedGroups(id: String) = transactional {
		Group.findAllHasUser(id)
	}

	def getSharedWalls(id: String) = transactional {

		val walls = query {
			// my shared wall + group's wall
			(user: User, wall: Wall, group: Group, uig: UserInGroup, wig: WallInGroup) =>
				where((user.id :== id) :&&
					(wall :== wig.wall) :&& (wig.group :== group) :&&
					((uig.user :== user) :&& (uig.group :== wig.group))) select (wall)
		}

		walls
	}

	def getWallsInGroups(id: String) = transactional {

		val groupwalls = query {
			// my shared wall + group's wall
			(user: User, wall: Wall, group: Group, uig: UserInGroup, wig: WallInGroup) =>
				where((user.id :== id) :&&
					(wall :== wig.wall) :&& (wig.group :== group) :&&
					((uig.user :== user) :&& (uig.group :== wig.group))) select (wall, group)
		}

		groupwalls
	}

	def getNonSharedWalls(id: String) = transactional {
		val sharedWalls = getSharedWalls(id)
		val ownWalls = Wall.findAllOwnedByUser(id)
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
