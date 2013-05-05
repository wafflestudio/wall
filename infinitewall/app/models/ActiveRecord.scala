package models

import net.fwbrasil.activate.ActivateContext
import net.fwbrasil.activate.storage.relational.PooledJdbcRelationalStorage
import net.fwbrasil.activate.storage.relational.idiom.h2Dialect
import net.fwbrasil.activate.storage.memory.TransientMemoryStorage
import net.fwbrasil.activate.entity.Entity
import net.fwbrasil.activate.entity.Alias
import scala.reflect.runtime.universe._
import scala.language.postfixOps

object ActiveRecord extends ActivateContext {
//    val storage = new TransientMemoryStorage    
    val storage = new PooledJdbcRelationalStorage {
        val jdbcDriver = "org.h2.Driver"
        val user = "infinitewall"
        val password = ""
        //val url = "jdbc:h2:mem:infinitewall;DB_CLOSE_DELAY=-1"
        val url = "jdbc:h2:activatedwall"
        val dialect = h2Dialect
    }
    
    // FIXME: should be driven by database schema change
    val sessionToken = ""

}


abstract class ActiveRecord[ModelType <: Entity : Manifest] {
  import ActiveRecord._
  
  def findById(id:String):Option[ModelType] = transactional {
    byId[ModelType](id)
  }

  def findAll() = transactional {
    all[ModelType]
  }
  

  def delete(id:String) = transactional {
    byId[ModelType](id).map(_.delete)
  }
 
}

