package cream.components
{
import misc.INameable;
import eventing.eventdispatchers.INameChangeEventDispatcher;

public interface INameableComponent extends IComponent, INameable, INameChangeEventDispatcher
{
	
}

}