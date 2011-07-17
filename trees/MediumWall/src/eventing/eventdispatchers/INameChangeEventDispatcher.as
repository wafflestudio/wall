package eventing.eventdispatchers
{

public interface INameChangeEventDispatcher
{
	function addNameChangeEventListener(listener:Function):void;
	function removeNameChangeEventListener(listener:Function):void;
	
}
}