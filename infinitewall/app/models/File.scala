package models

import org.apache.commons.codec.digest.DigestUtils
import play.api.Play.current

object FileSequencer extends Sequencer("FileSequencer")

object File {
  def assignFilename = {
    val id = FileSequencer.next
    DigestUtils.shaHex(id.toString)
  }
}
