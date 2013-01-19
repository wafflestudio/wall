package models
import com.sun.crypto.provider.BlowfishCipher
import org.mindrot.jbcrypt.BCrypt
import play.api.Logger
import utils.Mailer
import GlobalPermission._
import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.util.Date

case class User(id: Pk[Long], val email: String, val hashedPW: String, val permission: Permission, val verified:Int)

object User extends ActiveRecord[User] {
	val tableName = "User"

	val simple = {
		field[Pk[Long]]("id") ~
			field[String]("email") ~
			field[String]("hashedPW") ~
			field[Int]("permission") ~ 
			field[Int]("verified") map {
				case id ~ email ~ hashedPW ~ permission ~ verified => User(id, email, hashedPW, GlobalPermission(permission), verified)
			}
	}

	def findByEmail(email: String): Option[User] = {
		DB.withConnection { implicit c =>
			SQL("select * from " + tableName + " where email = {email}").on('email -> email).as(User.simple.singleOpt)
		}
	}

	def authenticate(email: String, password: String): Option[User] = {
		findByEmail(email).flatMap { user =>
			if (BCrypt.checkpw(password, user.hashedPW)) {
				Some(user)
			}
			else
				None
		}
	}

	def signup(email: String, password: String): Option[User] = {
		DB.withConnection { implicit c =>
			SQL(""" 
      insert into User (id, email, hashedpw, permission) values (
        (select next value for user_seq),
        {email}, {hashedPW}, {permission}	
      )
    """).on(
				'email -> email,
				'hashedPW -> hashedPW(password),
				'permission -> GlobalPermission.NormalUser.id
			).executeUpdate()
		}

		findByEmail(email) match {
			case someUser @ Some(user) =>
				Mailer.sendVerification(user)
				someUser
			case None => None
		}
	}
	
	private def tenMinutesAgo() = {
		import java.util.Calendar
		import java.text.SimpleDateFormat
		val now = Calendar.getInstance()
		now.add(Calendar.MINUTE, 10)
		(new SimpleDateFormat("yyyy-MM-dd").format(now.getTime()),
		new SimpleDateFormat("HH:mm:ss").format(now.getTime()))
	}
	
	def verifyIdentity(token:String) = {
		DB.withConnection { implicit c =>
			val (date,time) = tenMinutesAgo
			val foundUser = SQL("""select * from User where verification_token = {token}
				and verification_toke_date >= {date} and verification_token_time >= {time}""").
				on('token -> token, 'date -> date, 'time -> time).as(User.simple.singleOpt)
				
			foundUser.map { user =>
				SQL("update User set verified=1,verification_token = null, verification_token_date = null, verification_token_time = null where id = {id}").on('id -> user.id.get)
			}
			
			foundUser
		}
	}

	def listGroups(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("select usergroup.* from UserInGroup as uig, UserGroup where uig.user_id = {id} and uig.group_id = usergroup.id").
				on('id -> id).as(Group.simple*)
		}
	}

	def listSharedWalls(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("select wall.* from WallInGroup as wig, Wall where wig.group_id in (select uig.group_id from UserInGroup as uig where uig.user_id = {id}) and wig.wall_id = wall.id").
				on('id -> id).as(Wall.simple*)
		}
	}

	def listNonSharedWalls(id: Long) = {
		val sharedWalls = listSharedWalls(id)
		val ownWalls = Wall.findAllByUserId(id)
		ownWalls filterNot (sharedWalls contains)
	}

	private def hashedPW(pw: String) = BCrypt.hashpw(pw, BCrypt.gensalt(12))
}
