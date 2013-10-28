package utils

import java.io.File
import play.api.libs.Files.TemporaryFile
import util.{ Failure, Try }

/**
 * User: kindone
 * Date: 13. 2. 20.
 */
object FileSystem {
	def moveTempFile(tmpfile: TemporaryFile, path: String, preferredName: String) = {
		var i = 0

		def buildName(name: String, suffix: String) = {
			val parts = name.split("[.]")
			parts.tail.foldLeft(parts(0) + suffix) { (acc, part) =>
				acc + "." + part
			}
		}

		def tryMove(): Try[(String, File)] = Try {
			val name = buildName(preferredName, if (i == 0) "" else s" (${i.toString})")
			val file = new File(path + "/" + name)
			i += 1
			tmpfile.moveTo(file)

			(name, file)
		}

		val trials = Stream.cons(tryMove(), Stream.continually(tryMove))

		trials.take(1000).find(a => a.isSuccess) match {
			case Some(succ) =>
				succ
			case None =>
				Failure(throw new java.io.IOException("error placing temp file"))
		}
	}
}
