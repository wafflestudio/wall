package components.elements.events
{
import flash.events.Event;

public class ChildrenEvent extends Event
{
	public static const DIMENSION_CHANGE:String = "dimensionChange";
	public static const CLOSE_ACTION:String = "closeAction";
	public static const ADDED:String = "added";
	public static const REMOVED:String = "remove";
	
	
	public var oldx:Number;
	public var oldy:Number;
	public var oldwidth:Number;
	public var oldheight:Number;
	public var x:Number;
	public var y:Number;
	public var width:Number;
	public var height:Number;
	
	
	public function ChildrenEvent(type:String, bubbles:Boolean=false, 
							  cancelable:Boolean=false, x:Number=0, y:Number=0, 
							  width:Number=0, height:Number=0)  {
		super(type, bubbles, cancelable);
		
		this.x = x;
		this.y = y;		
	}
	
	
	override public function clone():Event  {
		var cloneEvent:ChildrenEvent = new ChildrenEvent(type, bubbles, 
			cancelable, x, y, width, height);
		
		return cloneEvent;
	}
}
}