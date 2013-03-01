package utils

case class Operation(from: Int, length: Int, content: String)

class CharWithState(val char: Char, var insertedBy: Set[Int] = Set(), var deletedBy: Set[Int] = Set())

class StringWithState(str: String) {
  var list: List[CharWithState] = str.map { c =>
    new CharWithState(c)
  }.toList

  def apply(op: Operation, branch: Int): Operation = {
    var i = 0
    var iBranch = 0
    var insertPos = 0
    var alteredFrom = 0
    var numDeleted = 0
    var iAtIBranch = 0

    list = list.map { cs =>
      if (!cs.deletedBy.contains(branch) && (cs.insertedBy.isEmpty || cs.insertedBy == Set(branch))) {
        if (iBranch >= op.from && iBranch < op.from + op.length) {
          if (cs.deletedBy.isEmpty)
            numDeleted += 1
          cs.deletedBy += branch
          insertPos = i
        }
        else if (iBranch == op.from + op.length) {
          insertPos = i
        }
        iBranch += 1
        iAtIBranch = i + 1
      }
      i += 1
      cs
    }

    if (iBranch <= op.from)
      insertPos = iAtIBranch

    val inserted = op.content.map { c =>
      new CharWithState(c, Set(branch))
    }

    i = 0
    list.map { cs =>
      if (i < insertPos) {
        if (cs.deletedBy.isEmpty)
          alteredFrom += 1
      }
      i += 1
    }

    list = list.take(insertPos) ++ inserted.toList ++ list.drop(insertPos)
    Operation(alteredFrom, numDeleted, op.content)
  }

  def text = {
    list.flatMap { cs =>
      if (cs.deletedBy.isEmpty)
        Some(cs.char)
      else
        None
    }.mkString
  }

  def html = {

  }
}

object TextOperation extends App {
  val A = Array(Operation(2, 2, "in"), Operation(2, 2, ""), Operation(0, 0, "newlyInserted"), Operation(1, 3, ""))
  val B = Array(Operation(2, 2, "or"), Operation(3, 1, "R"), Operation(0, 3, ""))
  val base = new StringWithState("baseText")

  //	println(base.text)
  //	for(a <- A) {
  //		val a2 = base(a, 0)
  //		if(a != a2)
  //			println("altered op: " + a + " => " + a2)
  //		println(base.text)
  //		//println(base.html)
  //	}
  //	
  //	for(b <- B) {
  //		val b2 = base(b, 1)
  //		if(b != b2)
  //			println("altered op: " + b + " => " + b2)
  //		println(base.text)
  //		//println(base.html)
  //	}

}
