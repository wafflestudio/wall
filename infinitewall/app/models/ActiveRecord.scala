package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB


abstract class ActiveRecord[T] {
	val tableName:String
	
	def simple: anorm.RowParser[T]
	
	def findById(id: Long): Option[T] = {
		DB.withConnection { implicit c =>
			SQL("select * from " + tableName + " where id = {id}").on('id -> id).as(simple.singleOpt)
		}
	}
	
	def create(instance:T):Long
	
	def delete(id: Long) = {
		DB.withConnection { implicit c =>
			SQL("delete from " + tableName + " where id = {id}").on(
				'id -> id
			).executeUpdate()
		}
	}
}