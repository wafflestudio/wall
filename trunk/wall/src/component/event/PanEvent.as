package component.event  {

import flash.events.Event;
	


public class PanEvent extends Event
{	
	public static const PAN_START:String = "panStart";
	public static const PAN:String = "pan";
	public static const PAN_END:String = "panEnd";
	
	
	public var x:Number;
	public var y:Number;
	
	public function PanEvent(type:String, bubbles:Boolean=false, 
								 cancelable:Boolean=false, x:Number=0, 
								 y:Number=0)  {
		super(type, bubbles, cancelable);
		
		this.x = x;
		this.y = y;		
	}

	
	override public function clone():Event  {
		var cloneEvent:PanEvent = new PanEvent(type, bubbles, 
			cancelable, 
			x, y);
		
		return cloneEvent;
	}
	
	

	

	
}
}