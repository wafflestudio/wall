package cream.components.contents
{
	import cream.components.buttons.Button;
	import cream.eventing.eventdispatchers.IClickEventDispatcher;
	import cream.eventing.events.ClickEvent;
	import cream.storages.IXMLizable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.core.IVisualElement;
	
	import spark.components.BorderContainer;

	public class ImageContent extends Content
	{
		private var imageContainer:BorderContainer = new BorderContainer();
		private var bitmapData:BitmapData;
		private var imageFile:File;	
		private var savedWidth:uint;
		private var savedHeight:uint;
		
		public function ImageContent()
		{
			super();
			
			imageContainer.setStyle("borderAlpha", 0);
			imageContainer.width = 0;
			imageContainer.height = 0;
			visualElement = imageContainer;
			
		}

		public override function set width(val:Number):void
		{
			savedWidth = val;
			if(bitmapData)  {
				imageContainer.scaleX = (val/bitmapData.width);
				trace(imageContainer.scaleX);
			}
			
		}
		
		public override function set height(val:Number):void
		{
			savedHeight = val;
			if(bitmapData)
				imageContainer.scaleY = (val/bitmapData.height);
		}
		
		public override function get width():Number { return savedWidth; }
		public override function get height():Number { return savedHeight; }

		public function set file(imageFile:File):void
		{
			this.imageFile = imageFile; 
			var loader:Loader = new Loader();
			
			var fs:FileStream = new FileStream();
			var ba:ByteArray = new ByteArray();
			fs.open(imageFile, FileMode.READ);
			fs.readBytes(ba, 0, fs.bytesAvailable);
			ba.position = 0;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
				bitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
				
				imageContainer.graphics.clear();
				imageContainer.graphics.beginBitmapFill(bitmapData, null, false);
				imageContainer.graphics.drawRect(0, 0, bitmapData.width, bitmapData.height);
				imageContainer.graphics.endFill();
				
				// if loading for the first time, width/height may be empty
				trace(savedWidth, savedHeight, width, height, bitmapData.width, bitmapData.height);
				width = (savedWidth == 0 ? bitmapData.width : savedWidth);
				height = (savedHeight == 0 ? bitmapData.height : savedHeight);
				
				
			});
			loader.loadBytes(ba);
			
		}
		
		public function get file():File
		{
			return imageFile;
		}
		
		/**
		 * 	<content>
		 * 		<image image="...">
		 * 	</content>
		 */ 	
		override public function toXML():XML {
			var xml:XML = super.toXML();
			var imageXML:XML = <image/>;
			imageXML.@image = imageFile.nativePath;
			xml.appendChild(imageXML);
			trace("imageContent toXML");
			return xml;
		}

		override public function fromXML(xml:XML):IXMLizable {
			trace("imageContent fromXML");
			var imagexml:XML = xml.image[0];
			file = File.applicationStorageDirectory.resolvePath(imagexml.@image);
			return this;
		}
	}
}