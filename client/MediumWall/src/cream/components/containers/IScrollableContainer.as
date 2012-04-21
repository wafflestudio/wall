package cream.components.containers
{
import cream.components.IComponent;
import flash.geom.Rectangle;
import cream.eventing.eventdispatchers.IChildrenDimensionChangeEventDispatcher;
import cream.eventing.eventdispatchers.IScrollEventDispatcher;
import cream.eventing.eventdispatchers.IDimensionChangeEventDispatcher;

public interface IScrollableContainer extends IContainer, 
	IChildrenDimensionChangeEventDispatcher
{
	
	
}
}