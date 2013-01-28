package test

import org.specs2.mutable._

import play.api.test._
import play.api.test.Helpers._

class HelloWorldSpec extends Specification {

  "The 'Hello world' string" should {
    "contain 11 characters" in {
      "Hello world" must have size(11)
    }
    "start with 'Hello'" in {
      "Hello world" must startWith("Hello")
    }
    "end with 'world'" in {
      "Hello world" must endWith("world")
    }
  }


  // fake application test

  "User model" should {

    "be retrieved by id" in {
      running(FakeApplication()) {
        val Some(admin) = models.User.findById(1000)

        admin.email must equalTo("admin@infinitewall.com")
        //macintosh. must beSome.which(dateIs(_, "1984-01-24"))
      }
    }
  }


  // fake request
}