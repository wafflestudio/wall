package models
import org.squeryl.PrimitiveTypeMode._

object Permission extends Enumeration {
	type Permission = Value
	val Administrator        = Value(1, "Administrator")
	val NormalUser           = Value(2, "Normal user")
	val NormalUserUnverified = Value(3, "Normal user not yet verified email")
}