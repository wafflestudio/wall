package eventing.events
{
import flash.geom.Rectangle;

public interface IDimensionChangeEvent extends IEvent
{
	function get dimension():Rectangle;
	function get oldDimension():Rectangle;
}
}