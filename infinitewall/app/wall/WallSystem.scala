package wall

import play.api.libs.iteratee._
import akka.actor._
import akka.util.duration._
import akka.pattern.ask
import akka.util.Timeout
import play.api.libs.concurrent._
import play.api.Play.current
import play.api.mvc.Result
import java.util.Date
import java.text.SimpleDateFormat
import java.util.Locale
import play.api.Logger
import play.api.libs.json._
import models.User
import models.WallLog
import java.sql.Timestamp
import models.Sheet
import utils.StringWithState
import utils.Operation

// Message
case class Join(userId: Long, timestamp: Long)
case class Quit(userId: Long, producer: Enumerator[JsValue])
case class Action(json: JsValue, producer: Enumerator[JsValue], detail: ActionDetail)

case class Connected(enumerator: Enumerator[JsValue], prevMessages: Enumerator[JsValue])
case class CannotConnect(msg: String)

case class Message(kind: String, username: String, text: String)

// Wall System (Delegate + Actor)
object WallSystem {

	implicit val timeout = Timeout(1 second)

	var walls: Map[Long, ActorRef] = Map()

	def wall(wallId: Long): ActorRef = {
		walls.get(wallId) match {
			case Some(wall) => wall
			case None =>
				val newActor = Akka.system.actorOf(Props(new WallActor(wallId)))
				walls = walls + (wallId -> newActor)
				newActor
		}
	}

	def establish(wallId: Long, userId: Long, timestamp: Long): Promise[(Iteratee[JsValue, _], Enumerator[JsValue])] = {

		val joinResult = wall(wallId) ? Join(userId, timestamp)

		joinResult.asPromise.map {
			case Connected(producer, prevMessages) =>
				// Create an Iteratee to consume the feed
				val consumer: Iteratee[JsValue, Unit] = Iteratee.foreach[JsValue] { json: JsValue =>
					Logger.info("received: " + json.toString)
					wall(wallId) ! Action(json, producer, ActionDetail(userId, json))
				}.mapDone { _ =>
					wall(wallId) ! Quit(userId, producer)
				}

				(consumer, prevMessages >>> producer)

			case CannotConnect(error) =>

				// Connection error

				// A finished Iteratee sending EOF
				val consumer = Done[JsValue, Unit]((), Input.EOF)

				// Send an error and close the socket
				val producer = Enumerator[JsValue](JsObject(Seq("error" -> JsString(error)))).andThen(Enumerator.enumInput(Input.EOF))

				(consumer, producer)

		}

	}

}


case class Record(timestamp:Long, baseText:String, resultText:String, consolidated:Operation, conn:Enumerator[JsValue])

class WallActor(wallId: Long) extends Actor {

	// key: userId, values: list of sessions user have
	var connections = Map.empty[Long, List[PushEnumerator[JsValue]]]
	// trick to track pending messages for each session (session, timestamp, action)
	var recentRecords = List[Record]()
	
	
	def prevLogs(timestamp: Long) = {
		WallLog.list(wallId, timestamp)
	}

	def logMessage(kind: String, basetimestamp: Long, userId: Long, message: String) = {
		WallLog.create(kind, wallId, basetimestamp, userId, message)
	}

	implicit def toDouble(value: JsValue) = { value.as[Double] }
	implicit def toLong(value: JsValue) = { value.as[Long] }

	def receive = {
		case Join(userId, timestamp) => {
			// Create an Enumerator to write to this socket
			val producer = Enumerator.imperative[JsValue]()
			val prev = Enumerator(prevLogs(timestamp).map { walllog => WallLog.walllog2Json(walllog) }: _*)

			if (false /* maximum connection per user constraint here*/ ) {
				sender ! CannotConnect("You have reached your maximum number of connections.")
			}
			else {
				connections = connections + (userId -> (connections.getOrElse(userId, List()) :+ producer))
				sender ! Connected(producer, prev)
			}
		}
		case Action(detail, origin, c: CreateAction) =>
			val sheetId = Sheet.createInit(c.x, c.y, c.width, c.height, c.title, c.contentType, c.content, wallId)
			notifyAll("action", c.timestamp, c.userId, origin, (detail.as[JsObject] ++ JsObject(Seq("id" -> JsNumber(sheetId)))).toString)
		case Action(detail, origin, action: ActionDetailWithId) =>
			Sheet.findById(action.id) map { sheet =>
				
				action match {
					case a: MoveAction =>
						Sheet.move(a.id, a.x, a.y)
					case a: ResizeAction =>
						Sheet.resize(a.id, a.width, a.height)
					case a: RemoveAction =>
						Sheet.delete(a.id)
					case a: SetTitleAction =>
						Sheet.setTitle(a.id, a.title)
					case a: SetTextAction =>
						Sheet.setText(a.id, a.text)
					case a: AlterTextAction =>
					

						val records = recentRecords.filter(_.timestamp > a.timestamp)
						// simulate consolidation of records after timestamp
						var pending = a.operations // all mine with > a.timestamp	
						//Logger.info("ts:" + a.timestamp + " status: " + pending.size + "," + records.size)
						assert(pending.size-1 == records.filter(_.conn == origin).size)
						records.map { r =>
							if(r.conn == origin)  {	
								// consolidated
								pending = pending.drop(1)
							}
							else  { // apply arrived consolidated record
								val ss = new StringWithState(r.baseText)
								ss.apply(r.consolidated, 1)
								pending = pending.map { p =>
									OperationWithState(ss.apply(p.op, 0), p.msgId)
								}
								//Logger.debug("simulation: " + ss.text)
							}
						}
						
						val alteredAction = pending.head.op
						
						val (baseText,resultText) = Sheet.alterText(a.id, alteredAction.from, alteredAction.length, alteredAction.content)
						// keep track of pending text until disconnection
						//Logger.info("before:(" + a.timestamp + ") :" + detail.toString)
						val newAction = AlterTextAction(a.userId, a.timestamp, a.id, List(OperationWithState(alteredAction, a.operations.last.msgId)))
						val timestamp = notifyAll("action", action.timestamp, action.userId, origin, newAction.singleJson.toString)
						//Logger.info("after:(" + timestamp + ") :" +  newAction.singleJson.toString)
						
						recentRecords = recentRecords :+ Record(timestamp, baseText, resultText, alteredAction, origin)
				}
				
				action match {
					case a:AlterTextAction =>
					case _ =>
						notifyAll("action", action.timestamp, action.userId, origin, detail.toString)
				}
			}
			
			

		case Quit(userId, producer) => {
			// clear sessions for userid. if none exists for a userid, remove userid key.
			connections.get(userId).map { producers =>
				
				val newProducers = producers.filterNot(_ == producer)

				if (newProducers.isEmpty)
					connections = connections - userId
				else
					connections = connections + (userId -> newProducers)
			}

		}

	}

	def notifyAll(kind: String, basetimestamp: Long, userId: Long, origin: Enumerator[JsValue], detail: String) = {

		val username = User.findById(userId).get.email

		val logId = logMessage(kind, basetimestamp, userId, detail)

		val msg = JsObject(
			Seq(
				"kind" -> JsString(kind),
				"username" -> JsString(username),
				"detail" -> JsString(detail),
				"timestamp" -> JsNumber(logId)
			)
		)
 
		connections.foreach {
			case (_, producers) =>
				producers.map { producer =>
					if (producer == origin)
						producer.push(msg ++ JsObject(Seq("mine" -> JsBoolean(true), "timestamp" -> JsNumber(logId))))
					else
						producer.push(msg ++ JsObject(Seq("timestamp" -> JsNumber(logId))))
				}
		}

		logId
	}

}
