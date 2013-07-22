package models

import play.api.Play.current
import ActiveRecord._
import net.fwbrasil.activate.entity.Entity
import net.fwbrasil.activate.entity.Alias

@Alias("UserAuthenticator") // override with securesocial and activate
class Authenticator(var sid: String,
		var user: User,
		var provider: Option[String] = None, 
		var creationDateSS: Long,
		var lastUsed: Long,
		var expirationDate: Long,
		var updatedAt: Long = System.currentTimeMillis) extends Entity
{
	def frozen() = transactional {
		Authenticator.Frozen(id, sid, user.id, provider, creationDateSS, lastUsed, expirationDate, updatedAt)
	}
}

object Authenticator extends ActiveRecord[Authenticator] {

	case class Frozen(id: String, val sid: String, val userId: String, val provider: Option[String], val SS: Long, val lastUsed: Long, val expirationDate: Long, val updatedAt: Long)

	def findBySid(sid: String) = transactional {
  		(select[Authenticator] where(_.sid :== sid))
	  	.headOption
	}

	def deleteBySid(sid: String) = transactional {
		(select[Authenticator] where(_.sid :== sid)).map(
			authenticator => authenticator.delete
		)
	}

	def create(sid: String, userId: String, provider: String, creationDateSS: Long, lastUsed: Long, expirationDate: Long) {
		transactional {
			val user = User.findById(userId).get
			new Authenticator(sid, user, Some(provider), creationDateSS, lastUsed, expirationDate).frozen
		}
	}

	def update(sid: String, userId: String, provider: String, creationDateSS: Long, lastUsed: Long, expirationDate: Long) {
		transactional {
			findBySid(sid).map { authenticator =>
				authenticator.sid = sid
				authenticator.user = User.findById(userId).get
				authenticator.provider = Some(provider)
				authenticator.creationDateSS = creationDateSS
				authenticator.lastUsed = lastUsed
				authenticator.expirationDate = expirationDate
				authenticator.updatedAt = System.currentTimeMillis
			}
		}
	}
}
