package cream.eventing.eventdispatchers
{
public interface IMoveEventDispatcher extends IEventDispatcher
{
	function addMovingEventListener(listener:Function):void;
	function removeMovingEventListener(listener:Function):void;
	function addMovedEventListener(listener:Function):void;
	function removeMovedEventListener(listener:Function):void;
}
}