package cream.components.controls
{
	import cream.components.IClickableComponent;
	import cream.eventing.eventdispatchers.IRollEventDispatcher;
	import cream.eventing.events.ClickEvent;
	import cream.eventing.events.RollEvent;
	
	import flash.events.MouseEvent;
	
	import mx.core.BitmapAsset;
	import mx.events.FlexEvent;
	
	import resources.Assets;
	
	import spark.components.BorderContainer;
	import spark.components.Image;

	public class CloseControl extends Control implements IClickableComponent, IRollEventDispatcher
	{
//		private var bc:BorderContainer = new BorderContainer();
		private var image:Image = new Image();
		
		public function set imageSource(asset:BitmapAsset):void { image.graphics.clear();image.source = asset; image.width = asset.width; image.height = asset.height; }
		
		public function CloseControl()
		{
			image.width = 16;
			image.height = 16;
			image.graphics.beginFill(0);
			image.graphics.drawRect(0,0,16,16);
			image.graphics.endFill();
			
			visualElement = image;
			visualElementContainer = null;
		
			// default asset
//			imageSource = new Assets.close_png();
			
			
			visualElement.addEventListener(MouseEvent.ROLL_OVER, function():void
			{
				dispatchRollOverEvent();
			});
			
			visualElement.addEventListener(MouseEvent.ROLL_OUT, function():void
			{
				dispatchRollOutEvent();
			});
			
			visualElement.addEventListener(MouseEvent.CLICK, function():void
			{
				dispatchClickEvent();
			});
			
		}
		
		public function addClickEventListener(listener:Function):void
		{
			addEventListener(ClickEvent.CLICK, listener);
		}
		
		public function removeClickEventListener(listener:Function):void
		{
			removeEventListener(ClickEvent.CLICK, listener);
		}
		
		public function addRollOverEventListener(listener:Function):void
		{
			addEventListener(RollEvent.ROLL_OVER, listener);
		}
		
		public function removeRollOverEventListener(listener:Function):void
		{
			removeEventListener(RollEvent.ROLL_OVER, listener);
		}
		
		public function addRollOutEventListener(listener:Function):void
		{
			addEventListener(RollEvent.ROLL_OUT, listener);
		}
		
		public function removeRollOutEventListener(listener:Function):void
		{
			removeEventListener(RollEvent.ROLL_OUT, listener);
		}
		
		protected function dispatchRollOutEvent():void
		{
			dispatchEvent(new RollEvent(this, RollEvent.ROLL_OUT));
		}
		
		protected function dispatchRollOverEvent():void
		{
			dispatchEvent(new RollEvent(this, RollEvent.ROLL_OVER));	
		}
		
		protected function dispatchClickEvent():void
		{
			dispatchEvent(new ClickEvent(this));	
		}
	}
}