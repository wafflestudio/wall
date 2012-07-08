package test

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import models.ChatRoom
import models.User

class Anorm extends Specification {
	"Computer model" should {
		"be retrieved by id" in {
			running(FakeApplication()) {

				val Some(admin) = User.findById(0)

				admin.email must equalTo("Macintosh")
				
			}
		}
	}
}