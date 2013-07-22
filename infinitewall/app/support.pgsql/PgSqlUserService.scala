package securesocial.core.support.pgsql

import _root_.java.util.{Date, UUID}

import securesocial.core._
import providers.Token
import securesocial.core.UserId
import securesocial.core.PasswordInfo
import scala.Some

import play.api.{Logger, Application}
import securesocial.core._
import org.joda.time.DateTime
import securesocial.core.providers.Token
import securesocial.core.providers.Token

import models.{User, Token => UserToken}
import models.ActiveRecord
import models.ActiveRecord._

import play.api.Play.current
import scala.Some

class PgSqlUserService(application: Application) extends UserServicePlugin(application) {

	def find(id: UserId) = {
		if (Logger.isDebugEnabled) {
			Logger.debug("find...")
				Logger.debug("id = %s".format(id.id))
		}

		val socialUser = transactional {User.findById(id.id).map(user =>
				SocialUser(
					UserId(user.id, user.provider.get),
					user.firstName.get,
					user.lastName.get,
					user.firstName.get + " " + user.lastName.get,
					Some(user.email),
					None,
					AuthenticationMethod("userPassword"),
					None,
					None,
					Some(PasswordInfo("bcrypt", user.hashedPW, None))
					)
			)}

		if (Logger.isDebugEnabled) {
			Logger.debug("socialUser = %s".format(socialUser))
		}

		socialUser
	} // end find


	/**
	 * findByEmailAndProvider user
	 *
	 */
	def findByEmailAndProvider(email: String, providerId: String): Option[SocialUser] = {
		if (Logger.isDebugEnabled) {
			Logger.debug("findByEmailAndProvider...")
			Logger.debug("email = %s".format(email))
			Logger.debug("providerId = %s".format(providerId))
		}

		val socialUser = transactional { User.findByEmailAndProvider(email, providerId).map(user =>
				SocialUser(
					UserId(user.id, user.provider.get),
					user.firstName.get,
					user.lastName.get,
					user.firstName.get + " " + user.lastName.get,
					Some(user.email),
					None,
					AuthenticationMethod("userPassword"),
					None,
					None,
					Some(PasswordInfo("bcrypt", user.hashedPW, None))
				)
			)}

		if (Logger.isDebugEnabled) {
			Logger.debug("socialUser = %s".format(socialUser))
		}

		socialUser
	} // end findByEmailAndProvider


	/**
	 * save user
	 * (actually save or update)
	 *
	 */
	def save(user: Identity):Identity = {
		if (Logger.isDebugEnabled) {
			Logger.debug("save...")
			Logger.debug("user = %s".format(user))
		}

		val socialUser = transactional { User.findById(user.id.id).map (u =>
				SocialUser(
					UserId(u.id, u.provider.get),
					u.firstName.get,
					u.lastName.get,
					u.firstName.get + " " + u.lastName.get,
					Some(u.email),
					None,
					AuthenticationMethod("userPassword"),
					None,
					None,
					Some(PasswordInfo("bcrypt", u.hashedPW, None))
					)
			)}

		if (Logger.isDebugEnabled) {
			Logger.debug("socialUser = %s".format(socialUser))
		}

		if (socialUser == None) { // user not exists
			if (Logger.isDebugEnabled) {
				Logger.debug("INSERT")
			}

			User.create(user.id.id, user.id.providerId, user.firstName, user.lastName, user.email.get, user.passwordInfo.get.password)
		} else { // user exists
			if (Logger.isDebugEnabled) {
				Logger.debug("UPDATE")
			}

			User.update(user.id.id, user.id.providerId, user.firstName, user.lastName, user.email.get, user.passwordInfo.get.password)
		} // end else
		user
	} // end save

	/**
	 * save token
	 *
	 */
	def save(token: Token) {
		if (Logger.isDebugEnabled) {
			Logger.debug("save...")
			Logger.debug("token = %s".format(token))
			Logger.debug("timestamp(creation) = %s".format(token.creationTime.getMillis.toString))
			Logger.debug("timestamp(current) = %s".format(System.currentTimeMillis.toString))
		}

		if (Logger.isDebugEnabled) {
			Logger.debug("INSERT")
		}

		UserToken.create(token.uuid, token.email, token.creationTime.getMillis, token.expirationTime.getMillis, token.isSignUp)
	} // end save

	/**
	 * findToken
	 *
	 */
	def findToken(token: String): Option[Token] = {
		if (Logger.isDebugEnabled) {
			Logger.debug("findToken...")
			Logger.debug("token = %s".format(token))
		}

		val foundToken = transactional { UserToken.findByToken(token).map(userToken =>
				Token(
					userToken.uuid,
					userToken.email.get,
					new DateTime(userToken.createdAt.get),
					new DateTime(userToken.expireAt.get),
					userToken.isSignUp.get
				))}

		if (Logger.isDebugEnabled) {
			Logger.debug("foundToken = %s".format(foundToken))
		}

		foundToken
	} // end findToken


	/**
	 * deleteToken
	 *
	 */
	def deleteToken(uuid: String) {
		if (Logger.isDebugEnabled) {
			Logger.debug("deleteToken...")
				Logger.debug("uuid = %s".format(uuid))
		}

		UserToken.deleteByToken(uuid)
	} // end deleteToken


	/**
	 * deleteTokens
	 *
	 */
	def deleteTokens() {
		if (Logger.isDebugEnabled) {
			Logger.debug("deleteTokens...")
		}

		//UserToken.deleteAll()
	} // end deleteTokens

	/**
	 * deleteExpiredTokens
	 *
	 */
	def deleteExpiredTokens() {
		if (Logger.isDebugEnabled) {
			Logger.debug("deleteExpiredTokens...")
		}

		//UserToken.deleteExpiredTokens()
	} // end deleteExpiredTokens
} // end DbUserService
