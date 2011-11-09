package cream.storages.clipboards
{
	import cream.eventing.eventdispatchers.IClipboardPasteEventDispatcher;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.events.Event;

	public class Clipboard 
	{
		protected var sysClipboard:flash.desktop.Clipboard = flash.desktop.Clipboard.generalClipboard; 
		
		public function Clipboard()
		{	
			
		}
		
		public function copyTest():void
		{
			sysClipboard.setData(ClipboardFormats.TEXT_FORMAT, "app");
			trace('copied');
		}
		
//		public function addCopyEventListener(listener:Function):void
//		{
////			sysClipboard.
//		}
//		
//		public function removeCopyEventListener(listener:Function):void
//		{
//			
//		}
//		
//		public function addCutEventListener(listener:Function):void
//		{
//			
//		}
//		
//		public function removeCutEventListener(listener:Function):void
//		{
//			
//		}
//		
//		public function addPasteEventListener(listener:Function):void
//		{
//			
//		}
//		
//		public function removePasteEventListener(listener:Function):void
//		{
//			
//		}
		
//		public function get bitmap():BitmapData
//		{
//			
//		}
//		
//		public function get text():String
//		{
//			
//		}
//		
//		public function get richText():String
//		{
//				
//		}
//		
//		public function get html():String
//		{
//			
//		}
//		
//		public function get fileList():Array
//		{
//			
//		}
		
		
	}
}