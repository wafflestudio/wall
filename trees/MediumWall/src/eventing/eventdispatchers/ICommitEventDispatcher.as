package eventing.eventdispatchers
{
public interface ICommitEventDispatcher extends IEventDispatcher
{
	function addCommitEventListener(listener:Function):void;
	function removeCommitEventListener(listener:Function):void;
}
}