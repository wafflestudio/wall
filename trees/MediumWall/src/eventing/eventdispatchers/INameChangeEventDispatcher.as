package eventing.eventdispatchers
{
import eventing.events.INameChangeEvent;

public interface INameChangeEventDispatcher
{
	function addNameChangeEventListener(listener:Function):void;
	function removeNameChangeEventListener(listener:Function):void;
	
}
}