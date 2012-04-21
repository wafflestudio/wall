package cream.eventing.eventdispatchers
{

public interface IExternalDimensionChangeEventDispatcher extends IEventDispatcher
{
	function addExternalDimensionChangeEventListener(listener:Function):void;
	function removeExternalDimensionChangeEventListener(listener:Function):void;
}
}