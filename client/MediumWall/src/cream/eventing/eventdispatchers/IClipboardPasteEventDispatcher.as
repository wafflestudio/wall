package cream.eventing.eventdispatchers
{
	public interface IClipboardPasteEventDispatcher extends IEventDispatcher
	{
		function addPasteEventListener(listener:Function):void;
		function removePasteEventListener(listener:Function):void;
	}
}