package eventing.events
{
import components.IComponent;
import eventing.eventdispatchers.IEventDispatcher;

public class ComponentEvent extends Event
{
	
	public function get target():IComponent
	{
		return dispatcher as IComponent;
	}
	
	public function ComponentEvent(dispatcher:IEventDispatcher, type:String)
	{
		super(dispatcher, type);
	}
}
}