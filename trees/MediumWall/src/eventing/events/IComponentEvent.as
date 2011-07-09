package eventing.events
{
import components.IComponent;

public interface IComponentEvent extends IEvent
{
	function get target():IComponent;	
}
}