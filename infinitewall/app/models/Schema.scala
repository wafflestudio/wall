package models

import org.squeryl.Schema
import org.squeryl.PrimitiveTypeMode._
import org.squeryl.dsl.QueryDsl
import org.squeryl.KeyedEntity


object InfiniteWallSchema extends Schema {
	val users = table[User]
}

class InfiniteWallObject extends KeyedEntity[Long] {
  var id: Long = 0
}