package eventing.eventdispatchers
{
import eventing.events.IFileChooseEvent;

public interface IFileChooseEventDispatcher extends IEventDispatcher
{
	function addFileChoseEventListener(listener:Function):void;
	function removeFileChoseEventListener(listener:Function):void;
}
}