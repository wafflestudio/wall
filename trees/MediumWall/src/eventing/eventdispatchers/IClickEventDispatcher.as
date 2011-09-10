package eventing.eventdispatchers
{
import eventing.events.ClickEvent;

public interface IClickEventDispatcher extends IEventDispatcher
{
	function addClickEventListener(listener:Function):void;
	function removeClickEventListener(listener:Function):void;
	
}
}