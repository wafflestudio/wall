package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB
import java.sql.Timestamp

abstract class ActiveRecord[T] {
	val tableName: String

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

	def create(instance: T): Long

	def delete(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("delete from " + tableName + " where id = {id}").on(
				'id -> id
			).executeUpdate()
		}
	}
}
