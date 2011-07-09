package eventing.events
{
public interface ISelectionChangeEvent extends IEvent
{
	function get selectedIndex():int;
	function get selectedItem():Object;
}
}