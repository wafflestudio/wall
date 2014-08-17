package services

import akka.actor.Actor
import play.libs.Akka
import akka.actor.Props
import services.wall.WallService
import services.chat.ChatService
import play.api.libs.json.JsValue
import play.api.libs.iteratee.Iteratee
import play.api.libs.iteratee.Enumerator
import play.api.libs.iteratee.Concurrent
import play.api.libs.iteratee.Concurrent.Channel
import play.Logger
import scala.concurrent.promise
import scala.concurrent.Future
import play.api.libs.json.JsString
import play.libs.Json
import play.api.libs.json.JsString

case class RawMessage(userId: String, channel: Future[Channel[JsValue]], val content: JsValue)
case class EntryMessage(userId: String, channel: Future[Channel[JsValue]], val path: List[String], val content: JsValue, sessionType: Option[String] = None)
case class ServiceMessage(userId: String, channel: Future[Channel[JsValue]], content: JsValue)

case class Establish()
case class Connection(channel: Future[Channel[JsValue]], connectionId: Int)
case class Terminate(userId: String, channel: Future[Channel[JsValue]])
case class TerminateAt(userId: String, channel: Future[Channel[JsValue]], path: List[String])
case class TerminateConnection(userId: String, channel: Future[Channel[JsValue]])

object EntryService {

	lazy val entryService = Akka.system.actorOf(Props(new EntryService))

	def establish(userId: String) = {

		import play.api.libs.concurrent.Execution.Implicits._

		// create enumerator

		val channelPromise = promise[Channel[JsValue]]
		val channelFuture = channelPromise.future

		lazy val producer: Enumerator[JsValue] = Concurrent.unicast[JsValue](onStart = { channel =>
			/*self ! NotifyJoin(userId, connectionId)*/
			Logger.info("start")
			channelPromise success channel
			channel.push(JsString("connected"))
		}, onError = { (msg, input) =>
			Logger.info("error")
			entryService ! Terminate(userId, channelFuture)
		})

		// create iteratee that feeds in to EntryService as RawMessage
		lazy val consumer: Iteratee[JsValue, Unit] = Iteratee.foreach[JsValue] { event: JsValue =>
			Logger.info("event")
			entryService ! RawMessage(userId, channelFuture, event)
		}.map { _ =>
			Logger.info("done")
			entryService ! Terminate(userId, channelFuture)
		}

		(consumer, producer)
	}

	// comet
	def submit() = {

	}
}

class EntryService extends Actor with Service {

	lazy val wallService = Akka.system.actorOf(Props(new WallService))
	lazy val chatService = Akka.system.actorOf(Props(new ChatService))

	def toMessage(userId: String, channel: Future[Channel[JsValue]], json: JsValue) = {
		Logger.info(json.toString)
		val path = (json \ "path").as[String].split("/").toList
		val sessionType = (json \\ "type").headOption.map(_.as[String])
		EntryMessage(userId, channel, path, json, sessionType)
	}

	var connectedPaths = Map[Future[Channel[JsValue]], List[String]]()

	def trackConnection(channel: Future[Channel[JsValue]], path: List[String]) = {
		connectedPaths = connectedPaths + (channel -> path)
	}

	def untrackConnection(channel: Future[Channel[JsValue]]) = {
		connectedPaths = connectedPaths - channel
	}

	def propagateTerminate(userId: String, channel: Future[Channel[JsValue]]) = {
		for (connectionPath <- connectedPaths) {
			val (iteratee, path) = connectionPath
			path match {
				case "wall" :: rest =>
					wallService ! TerminateAt(userId, channel, rest)
				case "chat" :: rest =>
					chatService ! TerminateAt(userId, channel, rest)
				case _ =>
			}
		}
	}

	def receive = {
		case RawMessage(userId, channel, json) =>
			val message = toMessage(userId, channel, json)

			message.sessionType.map { sessionType =>
				sessionType match {
					case "join" =>
						trackConnection(channel, message.path)
					case "quit" =>
						untrackConnection(channel)
					case _ =>
				}
			}

			message.path match {
				case "wall" :: rest =>
					wallService ! EntryMessage(userId, channel, rest, message.content)
				case "chat" :: rest =>
					chatService ! EntryMessage(userId, channel, rest, message.content)
				case _ =>
					Logger.error(s"unable to identify path ($message.path)")
			}
		case Terminate(userId, channel) =>
			propagateTerminate(userId, channel)
		case _ =>
			Logger.error("unexpected message came")
	}
}