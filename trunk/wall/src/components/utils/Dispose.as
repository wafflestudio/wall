import flash.events.Event;
import mx.collections.ArrayCollection;

private var event_handlers:Array = [];
private var added_to_stage:Boolean = false;

public override function addEventListener(type:String, listener:Function, 
  useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
{
	super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	event_handlers.push( [ type, listener, useCapture, priority, useWeakReference] );
}

public override function removeEventListener(type:String, listener:Function, 
  useCapture:Boolean=false):void
{
	
	for(var i:int = 0; i < event_handlers.length; i++)
	{
		var item:Array = event_handlers[i];
		if(item[0] == type && item[1] == listener && item[2] == useCapture)
		{
			event_handlers.splice(i,1);
			break;	
		}
	}
	super.removeEventListener(type, listener, useCapture);
	
}

private function addAllEventHandlers(e:Event):void
{
	added_to_stage = true;
	for(var i:int = 0; i < event_handlers.length; i++)
	{
		var item:Array = event_handlers[i];
		super.addEventListener(item[0], item[1], item[2], item[3], item[4]);
	}
}

private function removeAllEventHandlers(e:Event):void
{
	added_to_stage = false;
	for(var i:int = 0; i < event_handlers.length; i++)
	{
		var item:Array = event_handlers[i];
		super.removeEventListener(item[0], item[1], item[2]);
	}
}

public override function initialize():void
{
	this.addEventListener(Event.ADDED_TO_STAGE, addAllEventHandlers);
	this.addEventListener(Event.REMOVED_FROM_STAGE, removeAllEventHandlers);
	super.initialize();
}

public function dispose():void
{
	if(added_to_stage)
	for(var i:int = 0; i < event_handlers.length; i++)
	{
		super.removeEventListener(event_handlers[0], event_handlers[1], event_handlers[2]);
	}
	event_handlers = [];
}