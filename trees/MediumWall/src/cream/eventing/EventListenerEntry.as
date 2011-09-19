package cream.eventing
{
public class EventListenerEntry
{
	public var type:String;
	public var listener:Function;
	
	public function EventListenerEntry(type:String, listener:Function)
	{
		this.type = type;
		this.listener = listener;
	}
}
}