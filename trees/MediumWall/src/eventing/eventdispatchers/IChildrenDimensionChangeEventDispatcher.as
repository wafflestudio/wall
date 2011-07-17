package eventing.eventdispatchers
{
public interface IChildrenDimensionChangeEventDispatcher extends IEventDispatcher
{
	function addChildrenDimensionChangeEventListener(listener:Function):void;
	function removeChildrenDimensionChangeEventListener(listener:Function):void;
}
}