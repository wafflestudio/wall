package models

import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.db.DB

case class WallPreference(id: Pk[Long], val alias: Option[String], val panX: Double, val panY: Double, val zoom: Double, userId: Long, wallId: Long)

object WallPreference extends ActiveRecord[WallPreference] {
  val tableName = "WallPreference"

  val simple = {
    field[Pk[Long]]("id") ~
      field[Option[String]]("alias") ~
      field[Double]("pan_x") ~
      field[Double]("pan_y") ~
      field[Double]("zoom") ~
      field[Long]("user_id") ~
      field[Long]("wall_id") map {
        case id ~ name ~ panX ~ panY ~ zoom ~ userId ~ wallId => WallPreference(id, name, panX, panY, zoom, userId, wallId)
      }
  }

  def create(userId: Long, wallId: Long, alias: Option[String] = None, panX: Double = 0.0, panY: Double = 0.0, zoom: Double = 1.0) = {
    DB.withConnection { implicit c =>
      val id = SQL("select next value for wallpreference_seq").as(scalar[Long].single)

      SQL(""" 
        insert into WallPreference (id, alias, pan_x, pan_y, zoom, user_id, wall_id) values (
          {id},
          {alias}, {panX}, {panY}, {zoom}, {userId}, {wallId}
        )
      """).on(
        'id -> id,
        'alias -> alias,
        'panX -> panX,
        'panY -> panY,
        'zoom -> zoom,
        'userId -> userId,
        'wallId -> wallId
      ).executeUpdate()

      id
    }
  }

  def find(userId: Long, wallId: Long) = {
    DB.withConnection { implicit c =>
      SQL("select * from WallPreference where user_id = {userId} and wall_id = {wallId}").on(
        'userId -> userId, 'wallId -> wallId).as(WallPreference.simple.singleOpt)
    }
  }

  def findOrCreate(userId: Long, wallId: Long) = {
    DB.withConnection { implicit c =>
      val maybePref = SQL("select * from WallPreference where user_id = {userId} and wall_id = {wallId}").on(
        'userId -> userId, 'wallId -> wallId).as(WallPreference.simple.singleOpt)

      val id = maybePref match {
        case Some(pref) =>
          pref.id.get
        case None =>
          create(userId, wallId)
      }

      SQL("select * from WallPreference where id = {id}").on(
        'id -> id).as(WallPreference.simple.single)

    }
  }

  def setView(userId: Long, wallId: Long, panX: Double, panY: Double, zoom: Double) = {
    DB.withConnection { implicit c =>
      val id = SQL("select next value for wallpreference_seq").as(scalar[Long].single)

      SQL(""" 
        update WallPreference set pan_x = {panX}, pan_y = {panY}, zoom = {zoom}
          where user_id = {userId} and wall_id = {wallId}
      """).on(
        'panX -> panX,
        'panY -> panY,
        'zoom -> zoom,
        'userId -> userId,
        'wallId -> wallId
      ).executeUpdate()

      id
    }
  }

}

