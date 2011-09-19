package cream.eventing.eventdispatchers
{
public interface IScrollEventDispatcher extends IEventDispatcher
{
	function addScrollEventListener(listener:Function):void;
	function removeScrollEventListener(listener:Function):void;	
}
}