package securesocial.core.support.securesocial

import scala.Right

import org.joda.time.DateTime

import models.ActiveRecord.Alias
import models.ActiveRecord.transactional
import models.{ Authenticator => UserAuthenticator }
import play.api.{ Application, Logger }
import securesocial.core.{ Authenticator, AuthenticatorStore, IdentityId }

class ActivateAuthenticatorStore(app: Application) extends AuthenticatorStore(app) {

	def save(authenticator: Authenticator): Either[Error, Unit] = {

		val foundAuthenticator = transactional { UserAuthenticator.findBySid(authenticator.id) }

		if (foundAuthenticator == None) { // user not exists

			UserAuthenticator.create(authenticator.id, authenticator.identityId.userId, authenticator.identityId.providerId, authenticator.creationDate.getMillis, authenticator.lastUsed.getMillis, authenticator.expirationDate.getMillis)
		} else { // user exists

			UserAuthenticator.update(authenticator.id, authenticator.identityId.userId, authenticator.identityId.providerId, authenticator.creationDate.getMillis, authenticator.lastUsed.getMillis, authenticator.expirationDate.getMillis)
		} // end else

		Right(())
	} // end save

	def find(id: String): Either[Error, Option[Authenticator]] = {

		val authenticator = transactional {
			UserAuthenticator.findBySid(id).map(userAuthenticator =>
				Authenticator(
					userAuthenticator.sid,
					IdentityId(userAuthenticator.user.id, userAuthenticator.provider.get),
					new DateTime(userAuthenticator.creationDate),
					new DateTime(userAuthenticator.lastUsed),
					new DateTime(userAuthenticator.expirationDate)))
		}

		Right((authenticator))
	} // end find

	def delete(id: String): Either[Error, Unit] = {

		transactional { UserAuthenticator.deleteBySid(id) }

		Right(())
	} // end delete user
}
