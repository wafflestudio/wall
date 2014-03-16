package models

import org.apache.commons.codec.digest.DigestUtils

object FileSequencer extends Sequencer("FileSequencer")

object File {
	def assignFilename = {
		val id = FileSequencer.next
		DigestUtils.shaHex(id.toString)
	}
}
