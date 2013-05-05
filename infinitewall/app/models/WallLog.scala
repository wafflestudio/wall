package models

import play.api.Play.current
import java.sql.Timestamp
import play.api.libs.json._
import ActiveRecord._

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
        "id" -> id,
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
  
/* ???
  def timestamp(wallId: Long) = {
    DB.withConnection { implicit c =>
      SQL("select MAX(time) from WallLog where wall_id = {wallId}").on(
        'wallId -> wallId
      ).as(scalar[Option[Long]].single) match {
          case Some(time) => time
          case None => 999
        }
    }
  }
*/
}
