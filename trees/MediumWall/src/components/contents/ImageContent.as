package components.contents
{
	import components.buttons.Button;
	import components.buttons.IButton;
	
	import eventing.eventdispatchers.IClickEventDispatcher;
	import eventing.events.ClickEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	
	import mx.core.IVisualElement;
	
	import spark.components.BorderContainer;

	public class ImageContent extends Content implements IImageContent
	{
		private var fileRef:FileReference;
		private var imageContainer:BorderContainer = new BorderContainer();
		private var loadBtn:IButton;
		
		//private static const THUMB_WIDTH:uint = 300; // 크기 조절시 필요
		//private static const THUMB_HEIGHT:uint = 300;
		
		override protected function get visualElement():IVisualElement { return imageContainer; }
		
		public function ImageContent()
		{
			super();
			
			//imageContainer.percentWidth = 100;
			//imageContainer.percentHeight = 30;
			imageContainer.setStyle("borderAlpha", 0);
			loadBtn = new Button();
			loadBtn.label = "Load Image";
			addChildTo(imageContainer, loadBtn);
			imageContainer.width = 0;
			imageContainer.height = 0;
			
			loadBtn.addClickEventListener(
				function(e:ClickEvent):void {
				loadFile();
			});
		}
		
		public function get loadImageButton():IClickEventDispatcher
		{
			return loadBtn;
		}
		
		private function loadFile():void
		{
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, onFileSelect);
			fileRef.browse();
		}
		
		private function onFileSelect(e:Event):void
		{
			fileRef.addEventListener(Event.COMPLETE, onFileLoadComplete);
			fileRef.load();
		}
		
		private function onFileLoadComplete(e:Event):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDataLoadComplete);
			loader.loadBytes(fileRef.data);
			fileRef = null;
		}
		
		private function onDataLoadComplete(e:Event):void
		{
			var bitmapData:BitmapData = Bitmap(e.target.content).bitmapData;
			//var matrix:Matrix = new Matrix();
			//matrix.scale(THUMB_WIDTH/bitmapData.width, THUMB_HEIGHT/bitmapData.height); // 크기 조절할 때 필요
			
			imageContainer.graphics.clear();
			imageContainer.graphics.beginBitmapFill(bitmapData, null, false);	//크기조절시 null->matrix
			imageContainer.graphics.drawRect(0, 0, bitmapData.width, bitmapData.height);
			imageContainer.graphics.endFill();
			removeChildFrom(imageContainer, loadBtn);
		}
		
	}
}