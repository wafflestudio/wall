package models

import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._
import ActiveRecord._
import scala.util.Try
import utils.Operation
import play.Logger

// Record used for tracking text change (cache)
case class AlterTextRecord(timestamp: Long, baseTimestamp: Long, baseText: String, resultText: String, uuid: String, msgId: Long, operation: Operation)

object WallTimestamp extends Sequencer("WallTimestamp")

class WallLog(val kind: String, val message: String, val timestamp: Long, val basetime: Long, val wall: Wall, val user: User) extends Entity {
	def frozen = transactional {
		WallLog.Frozen(id, kind, message, timestamp, basetime, wall.id, user.id, user.email)
	}
}

object WallLog extends ActiveRecord[WallLog] {

	case class Frozen(id: String, kind: String, message: String, timestamp: Long, basetime: Long, wallId: String, userId: String, email: String) {
		def toJson: JsValue = {
			Json.obj(
				"wallLogId" -> id,
				"kind" -> kind,
				"username" -> email,
				"detail" -> message,
				"timestamp" -> timestamp,
				"basetimestamp" -> basetime)
		}
	}

	def list(wallId: String, timestamp: Long) = transactional {
		query {
			(log: WallLog) => where((log.wall.id :== wallId) :&& (log.timestamp :> timestamp)) select (log) orderBy (log.timestamp asc)
		}
	}

	def create(kind: String, wallId: String, basetime: Long, userId: String, message: String) = transactional {
		val wall = Wall.findById(wallId).get
		val user = User.findById(userId).get
		val timestamp = WallTimestamp.next

		new WallLog(kind, message, timestamp, basetime, wall, user)
	}

	def timestamp(wallId: String) = transactional {
		query {
			(log: WallLog) => where(log.wall.id :== wallId) select (log) orderBy (log.timestamp desc) limit (1)
		}.headOption match {
			case Some(log) => log.frozen.timestamp
			case None => 0
		}
	}

	def listAlterTextRecord(wallId: String, sheetId: String, timestamp: Long) = transactional {
		val content = TextContent.findBySheetId(sheetId).get
		val finalText = content.text

		// order by large timestamp first..
		val logs = query {
			(log: WallLog) => where((log.wall.id :== wallId) :&& (log.timestamp :> timestamp) :&& (log.kind :== "action")) select (log) orderBy (log.timestamp desc)
		}

		val operations = logs.filter { log =>
			Logger.debug(log.timestamp + "/" + log.message)
			Try {
				val json = Json.parse(log.message)
				(json \ "action").as[String] == "alterText" && (json \ "params" \ "sheetId").as[String] == sheetId
			}.getOrElse(false)
		}.foldLeft[(List[AlterTextRecord], String)]((List(), finalText)) { (pair, log) =>
			val json = Json.parse(log.message)
			val r = json \ "params"
			val u = json \ "undo"
			val uuid = (json \ "uuid").asOpt[String].getOrElse((json \ "connectionId").asOpt[Int].map(_.toString).get)
			val timestamp = (json \ "timestamp").as[Long]
			val redo = new Operation((r \ "from").as[Int],
				(r \ "length").as[Int],
				(r \ "content").as[String])
			val undo = new Operation((u \ "from").as[Int],
				(u \ "length").as[Int],
				(u \ "content").as[String])
			val msgId = (r \ "msgId").as[Long]
			val resultText = pair._2
			val baseText = undo.apply(resultText)
			val record = AlterTextRecord(timestamp = log.timestamp, baseTimestamp = timestamp, uuid = uuid, msgId = msgId,
				operation = redo, baseText = baseText, resultText = resultText)
			val list = pair._1
			(list :+ record, baseText)
		}
		Logger.debug(operations._1.toString)
		operations._1.reverse

	}

}
