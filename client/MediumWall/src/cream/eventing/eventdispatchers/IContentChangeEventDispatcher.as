package cream.eventing.eventdispatchers
{
public interface IContentChangeEventDispatcher extends IEventDispatcher
{
	function addContentChangeEventListener(listener:Function):void;
	function removeContentChangeEventListener(listener:Function):void;	
}
}