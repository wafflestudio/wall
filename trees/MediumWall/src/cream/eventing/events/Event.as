package cream.eventing.events
{
import cream.eventing.eventdispatchers.IEventDispatcher;

public class Event
{
	public static const DEFAULT:String = "default";
	protected var _type:String;
	protected var _dispatcher:IEventDispatcher;
	
	public function Event(dispatcher:IEventDispatcher, type:String = DEFAULT)
	{
		this._type = type;
		this._dispatcher = dispatcher;
	}
	
	public function get type():String
	{
		return _type;
	}
	
	public function get dispatcher():IEventDispatcher
	{
		return _dispatcher;
	}
	
}
}