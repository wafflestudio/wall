package models

import java.util.Date

import scala.language.postfixOps

import org.apache.commons.codec.digest.DigestUtils

import com.typesafe.config.ConfigFactory

import net.fwbrasil.activate.ActivateContext
import net.fwbrasil.activate.entity.Entity
import net.fwbrasil.activate.storage.relational.PooledJdbcRelationalStorage
import net.fwbrasil.activate.storage.relational.idiom.{ h2Dialect, postgresqlDialect }
import play.Logger

object ActiveRecord extends ActivateContext {
	lazy val config = ConfigFactory.load
	lazy val host = config.getString("smtp.host")
	lazy val mode = if (play.Play.isProd) "production" else if (play.Play.isDev) "development" else "test"

	if (play.Play.isTest)
		Logger.info("Activating ActiveRecord in test mode")

	val storage = new PooledJdbcRelationalStorage {
		val jdbcDriver = config.getString(s"${mode}.db.driver")
		val user = config.getString(s"${mode}.db.user")
		val password = config.getString(s"${mode}.db.password")
		val url = config.getString(s"${mode}.db.url")
		val dialect = jdbcDriver match {
			case "org.postgresql.Driver" => postgresqlDialect
			case "org.h2.Driver" => h2Dialect
			case _ => h2Dialect
		}
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

