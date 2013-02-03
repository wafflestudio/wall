package unit.views

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import javax.security.auth.login.AppConfigurationEntry.LoginModuleControlFlag

/**
 * User: kindone
 * Date: 13. 1. 29.
 */
class TemplateSpec extends Specification {

  "respond to the index Action" in {

//    val result = controllers.Application.index("Bob")(FakeRequest())
//
//    status(result) must equalTo(OK)
//    contentType(result) must beSome("text/html")
//    charset(result) must beSome("utf-8")
//    contentAsString(result) must contain("Hello Bob")
      failure
  }.pendingUntilFixed("To be completed")


  "render template" in {
//    val html = views.html.index()
//
//    contentType(html) must equalTo("text/html")
//    contentAsString(html) must contain("Hello Coco")
    failure
  }.pendingUntilFixed("To be completed")
}
