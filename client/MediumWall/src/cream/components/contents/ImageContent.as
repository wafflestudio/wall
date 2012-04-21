package cream.components.contents
{
import cream.components.Composite;
import cream.components.IFileStoredComponent;
import cream.storages.IXMLizable;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
	
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import spark.components.BorderContainer;

	public class ImageContent extends Content implements IFileStoredComponent
	{
		private var imageContainer:BorderContainer;
		private var bitmapData:BitmapData;
		private var _file:File;
		private var savedWidth:uint;
		private var savedHeight:uint;

        override protected function get visualElement():IVisualElement {  return imageContainer;  }
        override protected function get visualElementContainer():IVisualElementContainer	{  return null;	}

		
		public function ImageContent()
		{
			super();
		}

        override protected function initUnderlyingComponents():void
        {
            imageContainer = new BorderContainer();
            imageContainer.setStyle("borderAlpha", 0);
            imageContainer.width = 0;
            imageContainer.height = 0;
        }

		public override function set width(val:Number):void
		{
			savedWidth = val;
			if(bitmapData)  {
				imageContainer.scaleX = (val/bitmapData.width);
				
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


        public function get relativePath():File {

            for(var node:Composite = parent; node != null; node = node._protected_::parent)  {
                var fileStoredAncestor = node as IFileStoredComponent;
                if(fileStoredAncestor)  {
                    var rpath:File = fileStoredAncestor.relativePath;
                    return rpath;
                }
            }
            return null;
        }
        
		public function set file(imageFile:File):void
		{
			this._file = imageFile;
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
				width = (savedWidth == 0 ? bitmapData.width : savedWidth);
				height = (savedHeight == 0 ? bitmapData.height : savedHeight);
				
				
			});
			loader.loadBytes(ba);
			
		}
		
		public function get file():File
		{
			return _file;
		}
        
        
        private function get nativePath():String
        {
            var relativePath:File = this.relativePath;
            var path:String;


            if(relativePath)
                path = relativePath.getRelativePath(_file);

            return path ? path : _file.nativePath;
        }
		
		/**
		 * 	<content>
		 * 		<image image="...">
		 * 	</content>
		 */ 	
		override public function toXML():XML {
			var xml:XML = super.toXML();
			var imageXML:XML = <image/>;

			imageXML.@file = nativePath;
			xml.appendChild(imageXML);
			
			return xml;
		}

		override public function fromXML(xml:XML):IXMLizable {
			
			var imagexml:XML = xml.image[0];
            // use relativePath if exists, else use default
            var searchPath:File = relativePath ? relativePath : File.applicationStorageDirectory;

			file = searchPath.resolvePath(imagexml.@file.toString());

			return this;
		}
	}
}