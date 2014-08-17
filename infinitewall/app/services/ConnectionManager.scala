package services

import akka.actor.{ Actor, actorRef2Scala }
import models.{ AlterTextRecord, Sheet, SheetLink, WallLog }
import models.ActiveRecord.transactional
import play.api.Logger
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.iteratee.{ Concurrent, Enumerator }
import play.api.libs.json.{ JsObject, JsValue, Json }
import play.api.libs.json._
import play.api.libs.json.Json.toJsFieldJsValueWrapper
import utils.{ StringWithState, UsageSet }

case class ConnectionInfo(uuid: String, connectionId: Int)

class ConnectionManager {
	val connectionUsage = new UsageSet
	case class Connection(enumerator: Enumerator[JsValue], channel: Concurrent.Channel[JsValue], uuid: String, connectionId: Int, isVolatile: Boolean = false)

	// key: userId, values: list of sessions user have
	private var connectionsPerUser = Map.empty[String, List[Connection]]

	def allocate = connectionUsage.allocate

	def free(connectionId: Int) = connectionUsage.free(connectionId)

	def addConnection(userId: String, uuid: String, enumerator: Enumerator[JsValue], channel: Concurrent.Channel[JsValue], connectionId: Int) = {
		connectionsPerUser = connectionsPerUser + (userId -> (connectionsPerUser.getOrElse(userId, List()) :+ Connection(enumerator, channel, uuid, connectionId)))
	}

	def removeConnection(userId: String, connectionId: Int) = {
		connectionUsage.free(connectionId)
		connectionsPerUser.get(userId).foreach { userConns =>
			val newUserConns = userConns.filter(_.connectionId != connectionId)
			if (newUserConns.isEmpty)
				connectionsPerUser = connectionsPerUser - userId
			else
				connectionsPerUser = connectionsPerUser + (userId -> newUserConns)
		}
	}

	def numConnections = connectionsPerUser.foldLeft[Int](0) { (num, userConnections) =>
		num + userConnections._2.length
	}

	def hasConnection = !connectionsPerUser.isEmpty && numConnections != 0

	def connectionsAsString = connectionsPerUser.foldLeft("") { (str, userConnections) =>
		str + userConnections._2.foldLeft("") { (str, conn) =>
			str + { if (str.isEmpty()) { "" } else { "," } } + conn.uuid
		}
	}

	def connections = connectionsPerUser.flatMap {
		case (_, userConns) =>
			userConns
	}

}