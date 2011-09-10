package eventing.events
{
	import eventing.eventdispatchers.IEventDispatcher;

	public class ZoomEvent extends Event
	{
		public static const ZOOM:String = "zoom";
		
		private var _oldZoomX:Number;
		private var _oldZoomY:Number;
		private var _zoomX:Number;
		private var _zoomY:Number;
		
		public function get oldZoomX():Number { return _oldZoomX; };
		public function get oldZoomY():Number { return _oldZoomY; };
		
		public function get zoomX():Number { return _zoomX; };
		public function get zoomY():Number { return _zoomY; };
		
		public function ZoomEvent(dispatcher:IEventDispatcher, oldZoomX:Number, oldZoomY:Number, zoomX:Number, zoomY:Number)
		{
			super(dispatcher, ZOOM);
			_oldZoomX = oldZoomX;
			_oldZoomY = oldZoomY;
			_zoomX = zoomX;
			_zoomY = zoomY;
		}
	}
}