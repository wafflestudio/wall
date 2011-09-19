package cream.components
{
import cream.eventing.eventdispatchers.IMoveEventDispatcher;

public interface IMovableComponent extends IPositionedComponent, IMoveEventDispatcher
{
}
}