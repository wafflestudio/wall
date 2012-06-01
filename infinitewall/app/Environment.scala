import play.api._

import models._
import anorm._
import org.squeryl._
import org.squeryl.adapters._
import org.squeryl.PrimitiveTypeMode._
import play.db.DB
import com.typesafe.config._
import org.h2.Driver

object Environment extends GlobalSettings {

	override def onStart(app: Application) {
		activateSqueryl(false)
	}

	def activateSqueryl(usingConsole: Boolean = true) {

		if (usingConsole) {
			val config = ConfigFactory.load()
			val dbURL = config.getString("db.default.url")
			val dbUser = config.getString("db.default.user")
			val dbPass = config.getString("db.default.password")
			val dbDriver = config.getString("db.default.driver")

			SessionFactory.concreteFactory = Some(() =>
				Session.create(java.sql.DriverManager.getConnection(dbURL, dbUser, dbPass), new H2Adapter))

			if (usingConsole)
				Class.forName(dbDriver);
		}
		else {
			SessionFactory.concreteFactory = Some(
				() => Session.create(DB.getDataSource().getConnection(),
					new H2Adapter));
		}
	}

	def dropSchema() {
		transaction {
			Session.cleanupResources
			//			Schema.drop
		}
	}

	def createSchema() {
		transaction {
			//			Schema.create
		}
	}

}


