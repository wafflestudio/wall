package models

import net.fwbrasil.activate.ActivateContext
import net.fwbrasil.activate.storage.relational.PooledJdbcRelationalStorage
import net.fwbrasil.activate.storage.relational.idiom.h2Dialect
import net.fwbrasil.activate.storage.memory.TransientMemoryStorage
import net.fwbrasil.activate.entity.Entity
import scala.reflect.runtime.universe._
import scala.language.postfixOps
import com.typesafe.config.ConfigFactory
import play.Logger
import org.apache.commons.codec.digest.DigestUtils
import java.util.Date

object ActiveRecord extends ActivateContext {
	lazy val config = ConfigFactory.load()
	lazy val host = config.getString("smtp.host")

	if (play.Play.isTest)
		Logger.info("Activating ActiveRecord in test mode")

	val storage = new PooledJdbcRelationalStorage {
		val jdbcDriver = "org.h2.Driver"
		val user = "infinitewall"
		val password = ""
		val url = if (play.Play.isTest) "jdbc:h2:mem:infinitewall;DB_CLOSE_DELAY=-1" else "jdbc:h2:activatedwall"
		val dialect = h2Dialect
	}

	lazy val sessionToken = transactional {
		val tokens = all[SessionToken]
		if (tokens.isEmpty)
			new SessionToken(DigestUtils.shaHex(new Date().toString)).token
		else tokens.map(_.token).head
	}

}

class SessionToken(val token: String) extends Entity

abstract class ActiveRecord[ModelType <: Entity: Manifest] {
	import ActiveRecord._

	def findById(id: String): Option[ModelType] = transactional {
		byId[ModelType](id)
	}

	def findAll() = transactional {
		all[ModelType]
	}

	def delete(id: String) {
		transactional {
			byId[ModelType](id).map(_.delete)
		}
	}
}

