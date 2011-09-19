package cream.eventing.eventdispatchers
{
public interface IResizeEventDispatcher extends IEventDispatcher
{
	function addResizingEventListener(listener:Function):void;
	function removeResizingEventListener(listener:Function):void;
	function addResizedEventListener(listener:Function):void;
	function removeResizedEventListener(listener:Function):void;
}
}