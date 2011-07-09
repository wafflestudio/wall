package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public interface IEvent
{
	function get type():String;
	function get dispatcher():IEventDispatcher;
}
}