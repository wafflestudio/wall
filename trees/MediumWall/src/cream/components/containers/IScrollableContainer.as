package cream.components.containers
{
import cream.components.IComponent;
import flash.geom.Rectangle;
import eventing.eventdispatchers.IChildrenDimensionChangeEventDispatcher;
import eventing.eventdispatchers.IScrollEventDispatcher;
import eventing.eventdispatchers.IDimensionChangeEventDispatcher;

public interface IScrollableContainer extends IContainer, 
	IChildrenDimensionChangeEventDispatcher
{
	
	
}
}