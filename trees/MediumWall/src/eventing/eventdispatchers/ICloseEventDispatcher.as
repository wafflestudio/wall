package eventing.eventdispatchers
{
	public interface ICloseEventDispatcher extends IEventDispatcher
	{
		function addCloseEventListener(listener:Function):void;
		function removeCloseEventListener(listener:Function):void;
	}
}