package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class CompositeEvent extends Event implements ICompositeEvent
{
	public static const CHILD_ADDED:String = "childAdded";
	public static const CHILD_REMOVED:String = "childRemoved";
	public static const ADDED:String = "added";
	public static const REMOVED:String = "removed";
	
	public function CompositeEvent(dispatcher:IEventDispatcher, type:String)
	{
		super(dispatcher, type);
	}
}
}