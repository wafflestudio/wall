package cream.eventing.events
{
	import cream.eventing.eventdispatchers.IEventDispatcher;
	
	import flash.desktop.ClipboardFormats;

	public class ClipboardEvent extends Event
	{
		public static const COPY:String = "copy";
		public static const CUT:String = "cut";
		public static const PASTE:String = "paste";
		
		public static const HTML_FORMAT:String = ClipboardFormats.HTML_FORMAT;
		public static const RICH_TEXT_FORMAT:String = ClipboardFormats.RICH_TEXT_FORMAT;
		public static const TEXT_FORMAT:String = ClipboardFormats.TEXT_FORMAT;
		public static const BITMAP_FORMAT:String = ClipboardFormats.BITMAP_FORMAT;
		public static const FILE_LIST_FORMAT:String = ClipboardFormats.FILE_LIST_FORMAT;
		public static const FILE_PROMISE_LIST_FORMAT:String = ClipboardFormats.FILE_PROMISE_LIST_FORMAT;
		public static const URL_FORMAT:String = ClipboardFormats.URL_FORMAT;
		
		public function get object():Object { return _object; }
		public function get format():String { return _format; }
		
		private var _object:Object;
		private var _format:String;
		
		public function ClipboardEvent(dispatcher:IEventDispatcher, type:String, format:String, object:Object)
		{
			super(dispatcher, type);
			
			this._format = format;
			this._object = object;
			
		}
	}
}