package securesocial.core.support.securesocial

import org.joda.time.DateTime

import models.ActiveRecord.Alias
import models.{ Token => UserToken, User }
import play.api.{ Application, Logger }
import securesocial.core._
import securesocial.core.providers.Token

class ActivateUserService(application: Application) extends UserServicePlugin(application) {

	def find(id: IdentityId) = {
		Logger.debug("find...")
		Logger.debug("id = %s".format(id.userId))

		val socialUser =
			User.findById(id.userId).map(_.frozen).map { user =>
				SocialUser(
					IdentityId(user.id, user.provider.get),
					user.firstName.get,
					user.lastName.get,
					user.firstName.get + " " + user.lastName.get,
					Some(user.email),
					None,
					AuthenticationMethod("userPassword"),
					None,
					None,
					Some(PasswordInfo("bcrypt", user.hashedPW, None)))
			}

		Logger.debug("socialUser = %s".format(socialUser))

		socialUser
	} // end find

	/**
	 * findByEmailAndProvider user
	 *
	 */
	def findByEmailAndProvider(email: String, providerId: String): Option[SocialUser] = {
		Logger.debug("findByEmailAndProvider...")
		Logger.debug("email = %s".format(email))
		Logger.debug("providerId = %s".format(providerId))

		val socialUser =
			User.findByEmailAndProvider(email, providerId).map(_.frozen).map { user =>
				SocialUser(
					IdentityId(user.id, user.provider.get),
					user.firstName.get,
					user.lastName.get,
					user.firstName.get + " " + user.lastName.get,
					Some(user.email),
					None,
					AuthenticationMethod("userPassword"),
					None,
					None,
					Some(PasswordInfo("bcrypt", user.hashedPW, None)))
			}

		Logger.debug("socialUser = %s".format(socialUser))

		socialUser
	} // end findByEmailAndProvider

	/**
	 * save user
	 * (actually save or update)
	 *
	 */
	def save(user: Identity): Identity = {

		val socialUser =
			User.findById(user.identityId.userId).map(_.frozen).map(u =>
				SocialUser(
					IdentityId(u.id, u.provider.get),
					u.firstName.get,
					u.lastName.get,
					u.firstName.get + " " + u.lastName.get,
					Some(u.email),
					None,
					AuthenticationMethod("userPassword"),
					None,
					None,
					Some(PasswordInfo("bcrypt", u.hashedPW, None))))

		Logger.debug("save: user = %s, socialUser = %s".format(user, socialUser))

		if (socialUser == None) { // user not exists
			Logger.debug("INSERT")

			User.create(user.identityId.userId, user.identityId.providerId, user.firstName, user.lastName, user.email.get, user.passwordInfo.getOrElse(PasswordInfo("bcrypt", System.currentTimeMillis.toString, None)).password)
		} else { // user exists
			Logger.debug("UPDATE")

			User.update(user.identityId.userId, user.identityId.providerId, user.firstName, user.lastName, user.email.get, user.passwordInfo.getOrElse(PasswordInfo("bcrypt", System.currentTimeMillis.toString, None)).password)
		} // end else
		user
	} // end save

	/**
	 * save token
	 *
	 */
	def save(token: Token) {
		Logger.debug("save...")
		Logger.debug("token = %s".format(token))
		Logger.debug("timestamp(creation) = %s".format(token.creationTime.getMillis.toString))
		Logger.debug("timestamp(current) = %s".format(System.currentTimeMillis.toString))

		Logger.debug("INSERT")

		UserToken.create(token.uuid, token.email, token.creationTime.getMillis, token.expirationTime.getMillis, token.isSignUp)
	} // end save

	/**
	 * findToken
	 *
	 */
	def findToken(token: String): Option[Token] = {
		Logger.debug("findToken...")
		Logger.debug("token = %s".format(token))

		val foundToken =
			UserToken.findByToken(token).map(_.frozen).map(userToken =>
				Token(
					userToken.uuid,
					userToken.email.get,
					new DateTime(userToken.createdAt.get),
					new DateTime(userToken.expireAt.get),
					userToken.isSignUp.get))

		Logger.debug("foundToken = %s".format(foundToken))

		foundToken
	} // end findToken

	/**
	 * deleteToken
	 *
	 */
	def deleteToken(uuid: String) {
		Logger.debug("deleteToken...")
		Logger.debug("uuid = %s".format(uuid))

		UserToken.deleteByToken(uuid)
	} // end deleteToken

	/**
	 * deleteTokens
	 *
	 */
	def deleteTokens() {
		Logger.debug("deleteTokens...")

		//UserToken.deleteAll()
	} // end deleteTokens

	/**
	 * deleteExpiredTokens
	 *
	 */
	def deleteExpiredTokens() {
		Logger.debug("deleteExpiredTokens...")

		//UserToken.deleteExpiredTokens()
	} // end deleteExpiredTokens
} // end DbUserService
