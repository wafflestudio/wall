package unit.utils

import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import utils.UsageSet

class UsageSetSpec extends Specification {
  "UsageSet" should {
    
    val set = new UsageSet(5)

    "increase slot initially" in {
      
      set.allocate must be equalTo 0
      set.allocate must be equalTo 1
      set.allocate must be equalTo 2
      set.size must be equalTo 3
      
    }
    
    
    "be freed as expected" in {
      
      set.free(1)
      set.size must be equalTo 2

    }
    
    "increase slot until max" in {
      
      set.allocate must be equalTo 3
      set.allocate must be equalTo 4
      set.size must be equalTo 4
      
    }
    
    "make slot reused from the start" in {
      
      set.allocate must be equalTo 1
      set.size must be equalTo 5
      
    }
    
    "return -1 if no more available slot left" in {
      
      set.allocate must be equalTo -1
      set.size must be equalTo 5
      set.allocate must be equalTo -1
      
    }
    
    "should work after freeing after full" in {
      
      set.free(0)
      set.size must be equalTo 4
      set.allocate must be equalTo 0
      set.size must be equalTo 5
      
    }
  }
}