package components
{
import misc.INameable;
import eventing.events.INameChangeEvent;
import eventing.eventdispatchers.INameChangeEventDispatcher;

public interface INameableComponent extends IComponent, INameable, INameChangeEventDispatcher
{
	
}

}