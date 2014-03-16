package models

import ActiveRecord._
import net.fwbrasil.activate.entity.Entity

@Alias("UserToken")
class Token(var uuid: String,
		var email: Option[String] = None,
		var createdAt: Option[Long] = None,
		var expireAt: Option[Long] = None,
		var isSignUp: Option[Boolean] = None) extends Entity {
	def frozen() = transactional(required) {
		Token.Frozen(id, uuid, email, createdAt, expireAt, isSignUp)
	}
}

object Token extends ActiveRecord[Token] {

	case class Frozen(id: String, val uuid: String, val email: Option[String], val createdAt: Option[Long], val expireAt: Option[Long], val isSignUp: Option[Boolean])

	def create(uuid: String, email: String, creationTime: Long, expirationTime: Long, isSignUp: Boolean) {
		transactional(required) {
			new Token(uuid, Some(email), Some(creationTime), Some(expirationTime), Option(isSignUp))
		}
	}

	def findByToken(uuid: String) = transactional(required) {
		(select[Token] where (_.uuid :== uuid))
			.headOption
	}

	def deleteByToken(uuid: String) = transactional {
		(select[Token] where (_.uuid :== uuid)).map(
			token => token.delete)
	}

	def deleteAll() = transactional {
		all[Token].map(_.delete)
	}

	def deleteExpiredTokens() = transactional {
		(select[Token] where (_.expireAt :< System.currentTimeMillis)).map(
			token => token.delete)
	}
}
