package eventing.eventdispatchers
{
public interface IDimensionChangeEventDispatcher extends IChangeEventDispatcher
{
	function addDimensionChangeEventListener(listener:Function):void;
	function removeDimensionChangeEventListener(listener:Function):void;
}
}