package eventing.eventdispatchers
{
import eventing.events.ISelectionChangeEvent;

public interface ISelectionChangeEventDispatcher extends IEventDispatcher
{
	function addSelectionChangeEventListener(listener:Function):void;
	function removeSelectionChangeEventListener(listener:Function):void;
	
}
}