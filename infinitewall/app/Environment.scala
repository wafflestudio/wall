import play.api._

import models._
import com.typesafe.config._
import org.h2.Driver
import models.ActiveRecord._
import models.DevMigration
import net.fwbrasil.activate.migration.Migration

object Environment extends GlobalSettings {

	override def onStart(app: Application) {
		Migration.execute(models.ActiveRecord, new models.DevMigration)
		//Migration.update(models.ActiveRecord)
		//transactional { /* force loading activate context */}
		//    Logger.info("ActiveRecord initialized at: " + ActiveRecord.timestamp.toString)
	}
}
