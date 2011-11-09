package cream.eventing.eventdispatchers
{
	public interface IClipboardSaveEventDispatcher
	{
		function addCopyEventListener(listener:Function):void;
		function removeCopyEventListener(listener:Function):void;
		function addCutEventListener(listener:Function):void;
		function removeCutEventListener(listener:Function):void;
	}
}