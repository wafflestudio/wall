package models
import org.squeryl.dsl.OneToMany
import org.squeryl.PrimitiveTypeMode._
import org.squeryl.KeyedEntity
import com.sun.crypto.provider.BlowfishCipher
import org.mindrot.jbcrypt.BCrypt
import play.api.Logger
import utils.Mailer
import Permission._

object User {
	def findById(id: Long): Option[User] = {
		inTransaction {
			InfiniteWallSchema.users.lookup(id)
		}
	}

	def authenticate(email: String, password: String): Option[User] = {
		inTransaction {

			from(InfiniteWallSchema.users)(
				user => where(user.email === email) select (user)
			).headOption.flatMap { user =>
					if (BCrypt.checkpw(password, user.hashedPW))
						Some(user)
					else
						None
				}
		}
	}

	def signup(email: String, password: String): Option[User] = {
		inTransaction {

			if (from(InfiniteWallSchema.users)(
				user => where(user.email === email) select (user)
			).isEmpty) {
				val newUser: User = InfiniteWallSchema.users.insert(new User(email, hashedPW(password), Permission.NormalUser))
				Mailer.sendVerification(newUser)
				Some(newUser)
			}
			else
				None
		}
	}

	private def hashedPW(pw: String) = BCrypt.hashpw(pw, BCrypt.gensalt(12))

}

class User(val email: String, val hashedPW: String, val permission: Permission) extends KeyedEntity[Long] {
	val id: Long = 0
	//	lazy val pictures: OneToMany[PictureRef] = OchazukeSchema.userToPicture.left(this)

}

