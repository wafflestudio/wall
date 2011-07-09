package eventing.eventdispatchers
{
public interface IContentChangeEventDispatcher extends IChangeEventDispatcher
{
	function addContentChangeEventListener(listener:Function):void;
	function removeContentChangeEventListener(listener:Function):void;	
}
}