package models
import com.sun.crypto.provider.BlowfishCipher
import org.mindrot.jbcrypt.BCrypt
import play.api.Logger
import utils.Mailer
import Permission._
import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.util.Date

case class User(id: Pk[Long], val email: String, val hashedPW: String, val permission: Permission)

object User {

	val simple = {
		get[Pk[Long]]("user.id") ~
		get[String]("user.email") ~
		get[String]("user.hashedPW") ~
		get[Int]("user.permission") map {
			case id ~ email ~ hashedPW ~ permission => User(id, email, hashedPW, Permission(permission))
		}
	}

	def findById(id: Long): Option[User] = {
		DB.withConnection { implicit c =>
			SQL("select * from USER where id = {id}").on('id -> id).as(User.simple.singleOpt)
		}
	}
	
	def findByEmail(email:String): Option[User] = {
		DB.withConnection { implicit c =>
			SQL("select * from USER where email = {email}").on('email -> email).as(User.simple.singleOpt)
		}
	}

	def authenticate(email: String, password: String): Option[User] = {
		findByEmail(email).flatMap { user =>
			if(BCrypt.checkpw(password, user.hashedPW)) {
				Some(user)
			}
			else
				None
		}
	}

	def signup(email: String, password: String): Option[User] = {
		
		DB.withConnection { implicit c =>
			SQL(""" 
				insert into USER values (
					(select next value for user_seq),
					{email}, {hashedPW}, {permission}	
				)
			""").on(
				'email -> email,
				'hashedPW -> hashedPW(password),
				'permission -> Permission.NormalUser.id
			).executeUpdate()
		}
		
		findByEmail(email) match {
			case someUser @ Some(user) =>
				Mailer.sendVerification(user)
				someUser
			case None => None
		}
	}

	private def hashedPW(pw: String) = BCrypt.hashpw(pw, BCrypt.gensalt(12))

}

