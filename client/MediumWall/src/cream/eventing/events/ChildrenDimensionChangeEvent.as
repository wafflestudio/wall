package cream.eventing.events
{
import flash.geom.Rectangle;
import cream.eventing.eventdispatchers.IEventDispatcher;

public class ChildrenDimensionChangeEvent extends ComponentEvent
{
	public static const CHILDREN_DIMENSION_CHANGE:String = "childrenDimensionChange";
	
	public function ChildrenDimensionChangeEvent(dispatcher:IEventDispatcher)
	{
		super(dispatcher, CHILDREN_DIMENSION_CHANGE);
		
	}
}
}