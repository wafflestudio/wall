package securesocial.core.support.securesocial

import org.joda.time.DateTime

import models.ActiveRecord.Alias
import models.{ Token => UserToken, User }
import play.api.{ Application, Logger }
import securesocial.core._
import securesocial.core.providers.Token

class ActivateUserService(application: Application) extends UserServicePlugin(application) {

	def find(id: IdentityId) = {

		val socialUser =
			User.find(id.userId).map(_.frozen).map { user =>
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

		socialUser
	} // end find

	/**
	 * findByEmailAndProvider user
	 *
	 */
	def findByEmailAndProvider(email: String, providerId: String): Option[SocialUser] = {

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

		socialUser
	} // end findByEmailAndProvider

	/**
	 * save user
	 * (actually save or update)
	 *
	 */
	def save(user: Identity): Identity = {

		val socialUser =
			User.find(user.identityId.userId).map(_.frozen).map(u =>
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

		if (socialUser == None) { // user not exists

			User.create(user.identityId.userId, user.identityId.providerId, user.firstName, user.lastName, user.email.get, user.passwordInfo.getOrElse(PasswordInfo("bcrypt", System.currentTimeMillis.toString, None)).password)
		} else { // user exists

			User.update(user.identityId.userId, user.identityId.providerId, user.firstName, user.lastName, user.email.get, user.passwordInfo.getOrElse(PasswordInfo("bcrypt", System.currentTimeMillis.toString, None)).password)
		} // end else
		user
	} // end save

	/**
	 * save token
	 *
	 */
	def save(token: Token) {
		UserToken.create(token.uuid, token.email, token.creationTime.getMillis, token.expirationTime.getMillis, token.isSignUp)
	} // end save

	/**
	 * findToken
	 *
	 */
	def findToken(token: String): Option[Token] = {

		val foundToken =
			UserToken.findByToken(token).map(_.frozen).map(userToken =>
				Token(
					userToken.uuid,
					userToken.email.get,
					new DateTime(userToken.createdAt.get),
					new DateTime(userToken.expireAt.get),
					userToken.isSignUp.get))

		foundToken
	} // end findToken

	/**
	 * deleteToken
	 *
	 */
	def deleteToken(uuid: String) {

		UserToken.deleteByToken(uuid)
	} // end deleteToken

	/**
	 * deleteTokens
	 *
	 */
	def deleteTokens() {

		//UserToken.deleteAll()
	} // end deleteTokens

	/**
	 * deleteExpiredTokens
	 *
	 */
	def deleteExpiredTokens() {

		//UserToken.deleteExpiredTokens()
	} // end deleteExpiredTokens
} // end DbUserService
