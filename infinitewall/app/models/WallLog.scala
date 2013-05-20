package models

import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._
import ActiveRecord._
import scala.util.Try
import utils.Operation

object WallTimestamp extends Sequencer("WallTimestamp")

class WallLog(val kind:String, val message:String, val timestamp:Long, val basetime:Long, val wall:Wall, val user:User) extends Entity
{
  def frozen = transactional {
    WallLog.Frozen(id, kind, message, timestamp, basetime, wall.id, user.id, user.email)
  }
}

object WallLog extends ActiveRecord[WallLog] {

  case class Frozen(id: String, kind: String, message: String, timestamp: Long, basetime: Long, wallId: String, userId: String, email:String)
  {
    def toJson:JsValue = {
      Json.obj(
        "wallLogId" -> id,
        "kind" -> kind,
        "username" -> email,
        "detail" -> message,
        "timestamp" -> timestamp,
        "basetimestamp" -> basetime
      )
    }
  }


  def list(wallId: String, timestamp: Long) = transactional {
    select[WallLog] where(log => (log.wall.id :== wallId) :&& (log.timestamp :> timestamp))
  }


  def create(kind: String, wallId: String, basetime: Long, userId: String, message: String) = transactional {
    val wall = Wall.findById(wallId).get
    val user = User.findById(userId).get
    val timestamp = WallTimestamp.next

    new WallLog(kind, message, timestamp, basetime, wall, user)
  }


  def timestamp(wallId:String) = transactional  {
    query {
      (log:WallLog) => where(log.wall.id :== wallId) select(log) orderBy(log.timestamp desc) limit(1)
    }.headOption match {
      case Some(log) => log.frozen.timestamp
      case None => 0
    }
  }
  
  def recentOperations(wallId:String, sheetId:String, timestamp:Long) = transactional {
    // TODO:working on...
    val content = TextContent.findBySheetId(sheetId).get
    val finalText = content.text
    
    val logs = query {
      (log:WallLog) => where((log.wall.id :== wallId) :&& (log.timestamp :>= timestamp) :&& (log.kind :== "")) select(log) orderBy(log.timestamp asc)
    }
    
    logs.filter { log =>
      val json = Json.parse(log.message)
      Try {
        (json \ "action").as[String] == "alterText" && (json \ "sheetId").as[String] == sheetId
      }.getOrElse(false)
    }.map { log =>
      val json = Json.parse(log.message)
      val u = json \ "undo"
      new Operation((u \ "from").as[Int],
          (u \ "length").as[Int],
          (u \ "content").as[String])
    }
    
  }
  
}
