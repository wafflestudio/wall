package cream.eventing.eventdispatchers
{
public interface IPanEventDispatcher extends IEventDispatcher
{
	function addPanningEventListener(listener:Function):void;
	function removePanningEventListener(listener:Function):void;
	function addPannedEventListener(listener:Function):void;
	function removePannedEventListener(listener:Function):void;
}
}