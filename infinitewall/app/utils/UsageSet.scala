package utils

import scala.collection.mutable.BitSet
import scala.util.control.Breaks._

object UsageSet {
  val MaxValue = 1000000
}

// mutable usageset
class UsageSet(val max:Int = UsageSet.MaxValue) {
  val bitset = BitSet()
  var pos = 0

  def allocate():Int = {
   
    val slot = (pos to max-1).toStream.find(!bitset(_)) match { 
      case Some(num) => 
        num 
      case None =>
        (0 to pos).toStream.find(!bitset(_)).getOrElse(-1)
       
    }
    
    if(slot >= 0)
    {
      if(bitset.contains(slot))
        throw new RuntimeException
      bitset.add(slot)
      pos = slot + 1
      if(pos >= max)
        pos = 0
    }
    
    slot
  }
  
  def free(id:Int) = {
    bitset.remove(id)
  }
  
  def size = bitset.size
  
  
}