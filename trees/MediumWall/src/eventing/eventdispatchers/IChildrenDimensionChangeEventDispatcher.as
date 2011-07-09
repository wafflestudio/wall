package eventing.eventdispatchers
{
public interface IChildrenDimensionChangeEventDispatcher extends IChangeEventDispatcher
{
	function addChildrenDimensionChangeEventListener(listener:Function):void;
	function removeChildrenDimensionChangeEventListener(listener:Function):void;
}
}