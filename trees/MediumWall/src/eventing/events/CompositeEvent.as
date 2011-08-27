package eventing.events
{
import components.IComposite;

import eventing.eventdispatchers.IEventDispatcher;

public class CompositeEvent extends Event
{
	public static const CHILD_ADDED:String = "childAdded";
	public static const CHILD_REMOVED:String = "childRemoved";
	public static const ADDED:String = "added";
	public static const REMOVED:String = "removed";
	
	private var _child:IComposite;
	
	public function get child():IComposite { return _child; }
	
	public function CompositeEvent(dispatcher:IEventDispatcher, type:String, child:IComposite = null)
	{
		super(dispatcher, type);
		_child = child;
	}
}
}