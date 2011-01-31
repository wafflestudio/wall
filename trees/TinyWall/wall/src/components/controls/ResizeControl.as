package components.controls
{
	import components.SpatialObject;
	import components.capabilities.Movability;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;

	public class ResizeControl extends UIComponent
	{
		protected var target:IResizable;
		protected var resizeStartPos:Point;
		protected var resizeGlobalLocalDiff:Point;
		
		public function ResizeControl(target:IResizable) 
		{
			super();
			this.target = target;			
			resizeInit();
			attachToTarget();
		}
		
		private function attachToTarget():void{
			this.graphics.beginFill(0xff0000);
			
			this.graphics.drawRect(this.target.width, this.target.height, 10, 10);
			Alert.show("target.width : " + this.target.width + ", target.height : "
				+ this.target.height);
			this.graphics.endFill();
			
			this.target.addElement(this);
		}
		
		private function resizeInit():void{
			this.addEventListener(MouseEvent.MOUSE_DOWN, resizeStart);
		}
		
		private function resizeStart(e:MouseEvent):void{
			resizeStartPos = target.parent.localToGlobal(new Point(target.width, target.height));
			resizeGlobalLocalDiff = resizeStartPos.subtract(new Point(e.stageX, e.stageY));
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, resize);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, resizeEnd);
		}
		
		private function resize(e:MouseEvent):void{
			var current:Point = ((new Point(e.stageX, e.stageY)).add(resizeGlobalLocalDiff));
			target.width = current.x;
			target.height = current.y;
			this.x = this.target.width - 11;
			this.y = this.target.height - 11;
			
		}
		
		private function resizeEnd(e:MouseEvent):void{
			var current:Point = target.parent.globalToLocal((new Point(e.stageX, e.stageY)).add(resizeGlobalLocalDiff));
			target.width = current.x;
			target.height = current.y;
			
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, resize);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, resizeEnd);
			this.x = this.target.width - 11;
			this.y = this.target.height - 11;
		}	
	}
}