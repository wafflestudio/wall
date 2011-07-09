package eventing.eventdispatchers
{
import eventing.events.IClickEvent;

public interface IClickEventDispatcher extends IEventDispatcher
{
	function addClickEventListener(listener:Function):void;
	function removeClickEventListener(listener:Function):void;
	function dispatchClickEvent(e:IClickEvent = null):void;
}
}