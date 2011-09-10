package eventing.eventdispatchers
{
	public interface IDialogEventDispatcher extends IEventDispatcher
	{
		function addConfirmEventDispatcher(listener:Function):void;
		function removeConfirmEventDispatcher(listener:Function):void;
		function addOKEventDispatcher(listener:Function):void;
		function removeOKEventDispatcher(listener:Function):void;
		function addCancelEventDispatcher(listener:Function):void;
		function removeCancelEventDispatcher(listener:Function):void;
	}
}