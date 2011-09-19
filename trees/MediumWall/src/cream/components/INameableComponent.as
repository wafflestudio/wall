package cream.components
{
import cream.storages.INameable;
import cream.eventing.eventdispatchers.INameChangeEventDispatcher;

public interface INameableComponent extends IComponent, INameable, INameChangeEventDispatcher
{
	
}

}