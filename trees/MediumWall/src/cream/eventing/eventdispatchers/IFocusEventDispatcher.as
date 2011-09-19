package cream.eventing.eventdispatchers
{
public interface IFocusEventDispatcher extends IEventDispatcher
{
	function addFocusInEventListener(listener:Function):void;
	function removeFocusInEventListener(listener:Function):void;
	function addFocusOutEventListener(listener:Function):void;
	function removeFocusOutEventListener(listener:Function):void;
}
}