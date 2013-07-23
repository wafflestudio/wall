package unit.models

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import models.ActiveRecord._
import models.Content
import models.Sheet
import models.Wall
import models.User
import models.ContentType
import models.TextContent
import play.Logger

/**
 * User: kindone
 * Date: 13. 1. 27.
 */
class ContentSpec extends Specification {

  "Content of a Sheet" should {
    "be accessed d by common id when the sheet was created" in {
      running(FakeApplication()) {
        transactional {
          User.create("test@wall.com", "password", "test", "test", "test@wall.com", "pa$$word")
          val user = User.findByEmail("test@wall.com").get
          val wall = Wall.create(user.id, "test wall")
          val sheet = Sheet.create(0, 0, 100, 100, "test sheet", ContentType.TextType, "test content", wall.id)
          val contentId = transactional {
            select[Content] where(_.sheet :== sheet)
          }.map { c =>
            Logger.info(c.id)
            c.id
          }.head
          
          byId[Content](contentId).map { c=>
            Logger.info(c.id)
          }
          
          byId[TextContent](contentId).map(c => Logger.info(c.id))
          true
        }
      }
    }
  }
}
