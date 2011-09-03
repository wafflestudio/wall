package eventing.events
{
import components.Composite;

import eventing.eventdispatchers.IEventDispatcher;

public class CompositeEvent extends Event
{
	public static const CHILD_ADDED:String = "childAdded";
	public static const CHILD_REMOVED:String = "childRemoved";
	public static const ADDED:String = "added";
	public static const REMOVED:String = "removed";
	
	private var _child:Composite;
	
	public function get child():Composite { return _child; }
	
	public function CompositeEvent(dispatcher:IEventDispatcher, type:String, child:Composite = null)
	{
		super(dispatcher, type);
		_child = child;
	}
}
}