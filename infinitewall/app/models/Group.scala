package models

import play.api.db.DB
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import java.sql.Timestamp
import java.util.Date

case class Group(id: Pk[Long], val name: String)

object Group extends ActiveRecord[Group] {
  val tableName = "Group"

  val simple = {
    field[Pk[Long]]("id") ~
    field[String]("name") map {
      case id ~ name => Group(id, name)
    }
  }
  def create(name:String) = {
    DB.withConnection { implicit c =>
      val id = SQL("select next value for group_seq").as(scalar[Long].single)
      SQL("""
        insert into Group values (
          {id},
          {name}
        )
      """).on(
        'id -> id,
        'title -> title
      ).executeUpdate()
      id
    }
  }

}
