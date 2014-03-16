package models

import ActiveRecord._

class Sequence(val name: String, var value: Long) extends Entity

class Sequencer(name: String) {
	import ActiveRecord._

	def next = transactional {
		val seqs = query {
			(sequence: Sequence) => where(sequence.name :== name) select (sequence) orderBy (sequence.value desc) limit (1)
		}
		val seq = seqs.headOption match {
			case Some(seq) =>
				seq.value += 1
				seq
			case None => new Sequence(name, 1)
		}
		seq.value
	}

	def last = transactional {
		val seqs = query {
			(sequence: Sequence) => where(sequence.name :== name) select (sequence) orderBy (sequence.value desc) limit (1)
		}

		seqs.headOption match {
			case Some(seq) => seq.value
			case None => 0
		}

	}
}