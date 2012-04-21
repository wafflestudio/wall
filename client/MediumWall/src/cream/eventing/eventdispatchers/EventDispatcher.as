package cream.eventing.eventdispatchers
{
import cream.eventing.EventListenerEntry;
import cream.eventing.events.Event;

import mx.collections.ArrayCollection;

public class EventDispatcher implements IEventDispatcher
{
	protected var self:EventDispatcher;
	
	public function EventDispatcher()
	{
		self = this;	
	}
	
	protected function dispatchEvent(e:Event):void
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