package component
{
	import mx.events.ResizeEvent;
	
	import spark.components.BorderContainer;
	
	import utils.IScrollable;
	
	
	// Resize event
	public class Wall extends BorderContainer implements IScrollable
	{
		private var _contentWidth : Number;
		private var _contentHeight : Number;
		
		public function Wall()
		{
			super();
			
			this.setStyle("borderColor", 0x0);
			this.setStyle("backgroundColor", 0xF2F2F2);
			
			_contentWidth = width;
			_contentHeight = height;
		}
		
		public function set contentWidth(value:Number):void
		{
			if(_contentWidth == value)
				return;
			_contentWidth = value;
			
			
		}
		
		public function set contentheight(value:Number):void
		{
			if(_contentHeight == value)
				return ;
			_contentHeight = value;
			// display scrollbar
			// reposition scrollbar
			//height(value);	
		}
		
		protected override function createChildren():void
		{
			
			// add scrollbar
		}
	}
}