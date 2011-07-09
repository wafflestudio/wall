package eventing.eventdispatchers
{
import mx.collections.ArrayCollection;
import eventing.events.IEvent;
import eventing.EventListenerEntry;
import flash.events.Event;

public class EventDispatcher implements IEventDispatcher
{
	
	public function EventDispatcher()
	{
			
	}
	
	protected function dispatchEvent(e:IEvent):void
	{
		for each(var entry:EventListenerEntry in entries)
		{
			if(entry.type == e.type)
				entry.listener(e);
		}
	}
	
	private var entries:ArrayCollection = new ArrayCollection([]);
	
	protected function addEventListener(type:String, listener:Function):void
	{
		entries.addItem(new EventListenerEntry(type, listener));
	}
	
	protected function removeEventListener(type:String, listener:Function):void
	{
		for(var i:int = entries.length-1; i >= 0; i--)
		{
			var entry:EventListenerEntry = entries[i];
			if(entry.type == type && entry.listener == listener)  {
				entries.removeItemAt(i);
			}
				
		}
	}
	
	protected function removeAllEventListeners(type:String = null):void
	{
		for(var i:int = entries.length-1; i >= 0; i--)
		{
			var entry:EventListenerEntry = entries[i];
			if(type ? entry.type == type : true)  {
				entries.removeItemAt(i);
			}
		}
	}
	
	
}
}