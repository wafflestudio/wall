package cream.eventing.eventdispatchers
{
import cream.eventing.events.ClickEvent;

public interface IClickEventDispatcher extends IEventDispatcher
{
	function addClickEventListener(listener:Function):void;
	function removeClickEventListener(listener:Function):void;
	
}
}