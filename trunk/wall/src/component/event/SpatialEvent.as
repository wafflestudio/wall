package component.event
{
	import flash.events.Event;
	
	public class SpatialEvent extends Event
	{
		public function SpatialEvent(type:String, bubbles:Boolean=false, 
				cancelable:Boolean=false, 
				x:Number=0, y:Number=0, w:Number=0, h:Number=0, r:Number=0)  {
			super(type, bubbles, cancelable);
			
			this.x = x;
			this.y = y;
			this.width = w;
			this.height = h;
			this.rotation = r;
		}
		public static const SCROLLING:String = "scrolling";
		public static const SCROLLED:String = "scrolled";
		public static const MOVING:String = "moving";
		public static const MOVED:String = "moved";
		public static const RESIZING:String = "resizing";
		public static const RESIZED:String = "resized";
		public static const ROTATING:String = "rotating";
		public static const ROTATED:String = "rotated";
		public static const ZOOMING:String = "zooming";
		public static const ZOOMED:String = "zoomed";
		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		public var rotation:Number;
		public var zoom:Number;
		
		override public function clone():Event  {
			var cloneEvent:SpatialEvent = new SpatialEvent(type, bubbles, cancelable, 
												x, y, width, height, rotation);
			
			return cloneEvent;
		}
		
	}
}