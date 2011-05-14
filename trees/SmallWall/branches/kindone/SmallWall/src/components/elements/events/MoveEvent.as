package components.elements.events  {

import flash.events.Event;
	


public class MoveEvent extends Event
{	
	public static const MOVE_START:String = "moveStart";
	public static const MOVE:String = "move";
	public static const MOVE_END:String = "moveEnd";
	
	
	public var x:Number;
	public var y:Number;
	
	public function MoveEvent(type:String, bubbles:Boolean=false, 
								 cancelable:Boolean=false, x:Number=0, 
								 y:Number=0)  {
		super(type, bubbles, cancelable);
		
		this.x = x;
		this.y = y;		
	}

	
	override public function clone():Event  {
		var cloneEvent:MoveEvent = new MoveEvent(type, bubbles, 
			cancelable, 
			x, y);
		
		return cloneEvent;
	}
	
	

	

	
}
}