package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB
import java.sql.Timestamp
import org.apache.commons.codec.digest.DigestUtils

case class ActiveRecordRow(timestamp:Timestamp)

object ActiveRecord extends ActiveRecord[ActiveRecordRow] {
  val tableName = "activerecord"
  val simple = {
    field[Timestamp]("initialized_timestamp") map {
      case timestamp =>  ActiveRecordRow(timestamp)
    }
  }

  lazy val timestamp = {
    DB.withConnection { implicit c =>
      SQL("select * from " + tableName).as(simple.single).timestamp
    }
  }

  lazy val sessionToken = {
    DigestUtils.shaHex(timestamp.toString)
  }
}

abstract class ActiveRecord[T] {
	val tableName: String
	
	def field[Type](fieldName:String)(implicit extractor: anorm.Column[Type]) = get[Type](tableName + "." + fieldName)(extractor)

	def simple: anorm.RowParser[T]

	implicit def rowToTimestamp: anorm.Column[Timestamp] = Column.nonNull { (value, meta) =>
		val MetaDataItem(qualified, nullable, clazz) = meta
		value match {
			case timestamp: Timestamp => Right(timestamp)
			case _ => Left(TypeDoesNotMatch("Cannot convert " + value + ":" + value.asInstanceOf[AnyRef].getClass + " to java.sql.Timestamp for column " + qualified))
		}
	}

	def timestampParser = scalar[Timestamp]

	def findById(id: Long): Option[T] = {
		DB.withConnection { implicit c =>
			SQL("select * from " + tableName + " where id = {id}").on('id -> id).as(simple.singleOpt)
		}
	}

	def delete(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("delete from " + tableName + " where id = {id}").on(
				'id -> id
			).executeUpdate()
		}
	}
}
