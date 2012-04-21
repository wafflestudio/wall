package cream.eventing.eventdispatchers
{
public interface IDimensionChangeEventDispatcher extends IEventDispatcher
{
	function addDimensionChangeEventListener(listener:Function):void;
	function removeDimensionChangeEventListener(listener:Function):void;
}
}