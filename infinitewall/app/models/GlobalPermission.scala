package models

object GlobalPermission extends Enumeration {

	val Administrator = "admin"
	val NormalUser = "normal"
	val NormalUserUnverified = "normal_verified"
}

object Mode extends Enumeration {
	type Permission = Value

	private val OTHER = 1
	private val GROUP = 2
	private val OWNER = 3

	private val NONE = 0
	private val READONLY = 1
	private val READWRITE = 2

	private def permission(owner: Int, group: Int, other: Int) = {
		owner << (OWNER - 1) * 2 + group << (GROUP - 1) * 2 + other << (OTHER - 1) * 2
	}

	val OOO = Value(permission(NONE, NONE, NONE))
	val OOR = Value(permission(NONE, NONE, READONLY))
	val OOW = Value(permission(NONE, NONE, READWRITE))
	val ORO = Value(permission(NONE, READONLY, NONE))
	val ORR = Value(permission(NONE, READONLY, READONLY))
	val ORW = Value(permission(NONE, READONLY, READWRITE))
	val OWO = Value(permission(NONE, READWRITE, NONE))
	val OWR = Value(permission(NONE, READWRITE, READONLY))
	val OWW = Value(permission(NONE, READWRITE, READWRITE))
	val ROO = Value(permission(READONLY, NONE, NONE))
	val ROR = Value(permission(READONLY, NONE, READONLY))
	val ROW = Value(permission(READONLY, NONE, READWRITE))
	val RRO = Value(permission(READONLY, READONLY, NONE))
	val RRR = Value(permission(READONLY, READONLY, READONLY))
	val RRW = Value(permission(READONLY, READONLY, READWRITE))
	val RWO = Value(permission(READONLY, READWRITE, NONE))
	val RWR = Value(permission(READONLY, READWRITE, READONLY))
	val RWW = Value(permission(READWRITE, READWRITE, READWRITE))
	val WOO = Value(permission(READWRITE, NONE, NONE))
	val WOR = Value(permission(READWRITE, NONE, READONLY))
	val WOW = Value(permission(READWRITE, NONE, READWRITE))
	val WRO = Value(permission(READWRITE, READONLY, NONE))
	val WRR = Value(permission(READWRITE, READONLY, READONLY))
	val WRW = Value(permission(READWRITE, READONLY, READWRITE))
	val WWO = Value(permission(READWRITE, READWRITE, NONE))
	val WWR = Value(permission(READWRITE, READWRITE, READONLY))
	val WWW = Value(permission(READWRITE, READWRITE, READWRITE))

}

