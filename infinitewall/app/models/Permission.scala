package models

object Permission extends Enumeration {
	case class PermissionValue(name: String) extends Val(name)
	val privateWrite = PermissionValue("priv.read")
	val publicRead = PermissionValue("pub.read")
	val publicWrite = PermissionValue("pub.write")
}
