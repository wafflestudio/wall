package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class NameChangeEvent extends Event implements INameChangeEvent
{
	public static const NAME_CHANGE:String = "nameChange";
	private var _name:String;
	
	public function set name(val:String):void
	{
		_name = val;	
	}
	
	public function get name():String
	{
		return _name;
	}
	
	public function NameChangeEvent(dispatcher:IEventDispatcher, name:String)
	{
		super(dispatcher, NAME_CHANGE);
		this.name = name;
	}
}
}