package eventing.eventdispatchers
{
import eventing.events.IEvent;

public interface IExternalDimensionChangeEventDispatcher extends IEventDispatcher
{
	function addExternalDimensionChangeEventListener(listener:Function):void;
	function removeExternalDimensionChangeEventListener(listener:Function):void;
}
}