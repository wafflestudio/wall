package eventing.events
{
public interface IResizeEvent extends IComponentEvent
{
	function get top():Number;
	function get left():Number;
	function get right():Number;
	function get bottom():Number;
}
}