package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class ExternalDimensionChangeEvent extends Event implements IExternalDimensionChangeEvent
{
	public static const EXTERNAL_DIMENSION_CHANGE:String = "externalDimensionChange";
	
	public function ExternalDimensionChangeEvent(dispatcher:IEventDispatcher)
	{
		super(dispatcher, EXTERNAL_DIMENSION_CHANGE);
	}
}
}