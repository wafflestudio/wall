package cream.eventing.eventdispatchers
{
	public interface IRollEventDispatcher extends IEventDispatcher
	{
		function addRollOverEventListener(listener:Function):void;
		function removeRollOverEventListener(listener:Function):void;
		
		function addRollOutEventListener(listener:Function):void;
		function removeRollOutEventListener(listener:Function):void;
	}
}