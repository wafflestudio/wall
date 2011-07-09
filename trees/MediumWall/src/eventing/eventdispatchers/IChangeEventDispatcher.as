package eventing.eventdispatchers
{
import eventing.events.IChangeEvent;

public interface IChangeEventDispatcher extends IEventDispatcher
{
	function addChangeEventListener(listener:Function):void;
	function removeChangeEventListener(listener:Function):void;
	
}
}