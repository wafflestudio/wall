package models

import org.apache.commons.codec.digest.DigestUtils
import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current

/**
 * User: kindone
 * Date: 13. 2. 17.
 */
object File {
  def assignFilename = {
    val id = DB.withConnection { implicit c =>
      SQL("select next value for uploaded_file_seq").as(scalar[Long].single)
    }
    DigestUtils.sha1Hex(id.toString)
  }
}
