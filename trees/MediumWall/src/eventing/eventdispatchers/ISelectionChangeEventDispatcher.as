package eventing.eventdispatchers
{

public interface ISelectionChangeEventDispatcher extends IEventDispatcher
{
	function addSelectionChangeEventListener(listener:Function):void;
	function removeSelectionChangeEventListener(listener:Function):void;
	
}
}