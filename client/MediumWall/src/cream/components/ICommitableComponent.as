package cream.components
{
import cream.eventing.eventdispatchers.ICommitEventDispatcher;

public interface ICommitableComponent extends IComponent, ICommitEventDispatcher
{
	
}
}