package eventing.events
{
import flash.geom.Rectangle;

public interface IDimensionChangeEvent extends IChangeEvent
{
	function get dimension():Rectangle;
	function get oldDimension():Rectangle;
}
}