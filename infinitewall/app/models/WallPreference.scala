package models

import ActiveRecord._

class WallPreference(var alias: Option[String], var panX: Double, var panY: Double, var zoom: Double, val user: User, val wall: Wall) extends Entity {
	def frozen = transactional {
		WallPreference.Frozen(id, alias, panX, panY, zoom, user.id, wall.id)
	}
}

object WallPreference extends ActiveRecord[WallPreference] {

	case class Frozen(id: String, val alias: Option[String], val panX: Double, val panY: Double, val zoom: Double, userId: String, wallId: String)

	def create(userId: String, wallId: String, alias: Option[String] = None, panX: Double = 0.0, panY: Double = 0.0, zoom: Double = 1.0) =
		transactional {
			val user = User.findById(userId).get
			val wall = Wall.findById(wallId).get
			new WallPreference(alias, panX, panY, zoom, user, wall)
		}

	def findForUserWall(userId: String, wallId: String) = transactional {
		select[WallPreference] where (pref => (pref.wall.id :== wallId) :&& (pref.user.id :== userId))
	}.headOption

	def findOrCreate(userId: String, wallId: String) = transactional {
		findForUserWall(userId, wallId).getOrElse {
			create(userId, wallId)
		}
	}

	def setView(userId: String, wallId: String, panX: Double, panY: Double, zoom: Double) = {
		transactional {
			findForUserWall(userId, wallId).map { pref =>
				pref.panX = panX
				pref.panY = panY
				pref.zoom = zoom
			}
		}
	}

}

