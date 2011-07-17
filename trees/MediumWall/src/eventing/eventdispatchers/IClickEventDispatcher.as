package eventing.eventdispatchers
{
import eventing.events.ClickEvent;

public interface IClickEventDispatcher extends IEventDispatcher
{
	function addClickEventListener(listener:Function):void;
	function removeClickEventListener(listener:Function):void;
	function dispatchClickEvent(e:ClickEvent = null):void;
}
}