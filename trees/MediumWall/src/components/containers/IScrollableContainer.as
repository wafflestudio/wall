package components.containers
{
import components.IComponent;
import flash.geom.Rectangle;
import eventing.eventdispatchers.IChildrenDimensionChangeEventDispatcher;
import eventing.eventdispatchers.IScrollEventDispatcher;
import eventing.eventdispatchers.IDimensionChangeEventDispatcher;

public interface IScrollableContainer extends IContainer, 
	IChildrenDimensionChangeEventDispatcher
{
	
	
}
}