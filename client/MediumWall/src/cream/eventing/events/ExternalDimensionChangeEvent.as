package cream.eventing.events
{
import cream.eventing.eventdispatchers.IEventDispatcher;

public class ExternalDimensionChangeEvent extends Event
{
	public static const EXTERNAL_DIMENSION_CHANGE:String = "externalDimensionChange";
	
	public function ExternalDimensionChangeEvent(dispatcher:IEventDispatcher)
	{
		super(dispatcher, EXTERNAL_DIMENSION_CHANGE);
	}
}
}