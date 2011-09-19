package cream.eventing.eventdispatchers
{

public interface IFileChooseEventDispatcher extends IEventDispatcher
{
	function addFileChoseEventListener(listener:Function):void;
	function removeFileChoseEventListener(listener:Function):void;
}
}