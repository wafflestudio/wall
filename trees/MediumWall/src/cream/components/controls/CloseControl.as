package cream.components.controls
{
	import cream.components.IClickableComponent;
	
	import eventing.eventdispatchers.IRollEventDispatcher;
	import eventing.events.ClickEvent;
	import eventing.events.RollEvent;
	
	import flash.events.MouseEvent;
	
	import spark.components.BorderContainer;

	public class CloseControl extends Control implements IClickableComponent, IRollEventDispatcher
	{
		private var bc:BorderContainer = new BorderContainer();
		
		public function CloseControl()
		{
			bc.width = 16;
			bc.height = 16;
			bc.setStyle("backgroundColor", 'red');
			
			visualElement = bc;
			visualElementContainer = null;
			
			bc.addEventListener(MouseEvent.ROLL_OVER, function():void
			{
				dispatchRollOverEvent();
			});
			
			bc.addEventListener(MouseEvent.ROLL_OUT, function():void
			{
				dispatchRollOutEvent();
			});
			
			bc.addEventListener(MouseEvent.CLICK, function():void
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