package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class ChangeEvent extends Event implements IChangeEvent
{
	public static const CHANGE:String = "change";
	
	public function ChangeEvent(dispatcher:IEventDispatcher)
	{
		super(dispatcher, CHANGE);
	}
}
}