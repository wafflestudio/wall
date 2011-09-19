package cream.components
{
import cream.misc.INameable;
import cream.eventing.eventdispatchers.INameChangeEventDispatcher;

public interface INameableComponent extends IComponent, INameable, INameChangeEventDispatcher
{
	
}

}