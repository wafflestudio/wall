package models

object Permission extends Enumeration {
	type Permission = Value
	val Administrator        = Value(1)
	val NormalUser           = Value(2)
	val NormalUserUnverified = Value(3)
}