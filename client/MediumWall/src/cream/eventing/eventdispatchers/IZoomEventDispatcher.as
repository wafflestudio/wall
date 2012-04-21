package cream.eventing.eventdispatchers
{
	public interface IZoomEventDispatcher
	{
		function addZoomedEventListener(listener:Function):void;
		function removeZoomedEventListener(listener:Function):void;
	}
}