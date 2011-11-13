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
		private var savedImageFilePath:String;	
		private var savedWidth:uint;
		private var savedHeight:uint;
		override protected function get visualElement():IVisualElement { return imageContainer; }
		
		
		public function ImageContent()
		{
			super();
			
			imageContainer.setStyle("borderAlpha", 0);
			imageContainer.width = 0;
			imageContainer.height = 0;
			
		}
		public function setImageFilePath(path:String):void {
			savedImageFilePath = path;
		}
		public function setSize(w:uint, h:uint):void {
			savedWidth = w;
			savedHeight = h;
		}
		public function resizeImage(w:int, h:int):void {
			trace("image resized width:"+w+"height:"+h);
			
			var matrix:Matrix = new Matrix();
			matrix.scale(w/bitmapData.width, h/bitmapData.height);
			
			imageContainer.graphics.clear();
			imageContainer.graphics.beginBitmapFill(bitmapData, matrix, false);
			imageContainer.graphics.drawRect(0, 0, w, h);
			imageContainer.graphics.endFill();

			
		}
		
		public function drawImage(imageFile:File):void {
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

				if(savedWidth) {
					resizeImage(savedWidth,savedHeight);
				}
			});
			loader.loadBytes(ba);
			
		}

		/**
		 * 	<content>
		 * 		<image image="...">
		 * 	</content>
		 */ 
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
			var imageXML:XML = <image/>;
			imageXML.@image = savedImageFilePath;
			xml.appendChild(imageXML);
			trace("imageContent toXML");
			return xml;
		}

		override public function fromXML(xml:XML):IXMLizable {
			trace("imageContent fromXML");
			var imagexml:XML = xml.image[0];
			savedImageFilePath = imagexml.@image;
			setImageFilePath(savedImageFilePath);
			var imageFile:File = new File(savedImageFilePath);
			drawImage(imageFile);
			return this;
		}
	}
}