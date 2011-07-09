package eventing.eventdispatchers
{
import eventing.events.IEvent;
import eventing.events.ICompositeEvent;

public interface ICompositeEventDispatcher extends IEventDispatcher
{
	function addChildAddedEventListener(listener:Function):void;
	function removeChildAddedEventListener(listener:Function):void;
	
	function addChildRemovedEventListener(listener:Function):void;
	function removeChildRemovedEventListener(listener:Function):void;
	
	function addAddedEventListener(listener:Function):void;
	function removeAddedEventListener(listener:Function):void;
	
	function addRemovedEventListener(listener:Function):void;
	function removeRemovedEventListener(listener:Function):void;
	
}
}