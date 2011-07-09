package components
{
import eventing.eventdispatchers.ICommitEventDispatcher;

public interface ICommitableComponent extends IComponent, ICommitEventDispatcher
{
	
}
}