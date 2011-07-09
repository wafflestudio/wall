package eventing.events
{
public interface IMoveEvent extends IEvent
{
	function get oldX():Number;
	function get oldY():Number;
	function get newX():Number;
	function get newY():Number;
}
}