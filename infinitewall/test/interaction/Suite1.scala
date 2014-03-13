package interaction

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._

import scala.concurrent._
import ExecutionContext.Implicits.global

import akka.util.Timeout
import scala.concurrent.duration._

class Suite1Spec extends Specification {

	override def intToRichLong(v: Int) = super.intToRichLong(v)

	sequential
	val serverPort = 19001 // = default
	val serverURL = "http://localhost" + ":" + serverPort

	"main page" should {
		"be available as expected" in {
			new WithServer( /*port = serverPort, app = FakeApplication()*/ ) {
				import scala.sys.process._
				val jsTest = Future {
					// run casperjs tests
					s"casperjs test/interaction/suite1.coffee $serverURL".!<
				}
				Await.result(jsTest, 300.seconds) must equalTo(0)
			}
		}
	}

}
