package cream.components
{
import eventing.eventdispatchers.IMoveEventDispatcher;

public interface IMovableComponent extends IPositionedComponent, IMoveEventDispatcher
{
}
}