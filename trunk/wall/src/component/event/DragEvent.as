package component.event  {

import flash.events.Event;
	


public class DragEvent extends Event
{	
	public static const DRAG_START:String = "dragStart";
	public static const DRAG:String = "drag";
	public static const DRAG_END:String = "dragEnd";
	
	
	public var x:Number;
	public var y:Number;
	
	public function DragEvent(type:String, bubbles:Boolean=false, 
								 cancelable:Boolean=false, x:Number=0, 
								 y:Number=0)  {
		super(type, bubbles, cancelable);
		
		this.x = x;
		this.y = y;		
	}

	
	override public function clone():Event  {
		var cloneEvent:DragEvent = new DragEvent(type, bubbles, 
			cancelable, 
			x, y);
		
		return cloneEvent;
	}
	
	

	

	
}
}