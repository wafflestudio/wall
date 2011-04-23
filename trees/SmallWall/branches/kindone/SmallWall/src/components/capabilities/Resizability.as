package components.capabilities
{
import components.events.SpatialEvent;
import components.SpatialObject;
import flash.events.MouseEvent;
import flash.geom.Point;
import components.controls.ResizeControl;
import mx.events.ResizeEvent;

public class Resizability
{
	
	private var obj:SpatialObject;
	private var resizeControl:ResizeControl;
	
	private var resizeStartPos:Point;
	private var resizeGlobalLocalDiff:Point;
	
	public function Resizability(target:SpatialObject) 
	{
		this.obj = target;			
		attachToTarget();
	}
	
	private function attachToTarget():void{
		resizeControl = new ResizeControl(obj);
		resizeControl.x = obj.width - 11;
		resizeControl.y = obj.height - 11;
		obj.addElement(resizeControl);
		resizeControl.addEventListener(MouseEvent.MOUSE_DOWN, resizeStart);
		obj.addEventListener(ResizeEvent.RESIZE, function (e:ResizeEvent):void  {
			resizeControl.x = obj.width - 11;
			resizeControl.y = obj.height - 11;
		});
	}
	
	private function resizeStart(e:MouseEvent):void{
		e.stopPropagation();
		resizeStartPos = obj.parent.localToGlobal(new Point(obj.width, obj.height));
		resizeGlobalLocalDiff = resizeStartPos.subtract(new Point(e.stageX, e.stageY));
		obj.stage.addEventListener(MouseEvent.MOUSE_MOVE, resize);
		obj.stage.addEventListener(MouseEvent.MOUSE_UP, resizeEnd);
	}
	
	private function resize(e:MouseEvent):void{
		var current:Point = obj.parent.globalToLocal((new Point(e.stageX, e.stageY)).add(resizeGlobalLocalDiff));
		obj.width = current.x;
		obj.height = current.y;
//		resizeControl.x = obj.width - 11;
//		resizeControl.y = obj.height - 11;
		
	}
	
	private function resizeEnd(e:MouseEvent):void{
		var current:Point = obj.parent.globalToLocal((new Point(e.stageX, e.stageY)).add(resizeGlobalLocalDiff));
		obj.width = current.x;
		obj.height = current.y;
		
		obj.stage.removeEventListener(MouseEvent.MOUSE_MOVE, resize);
		obj.stage.removeEventListener(MouseEvent.MOUSE_UP, resizeEnd);
//		resizeControl.x = obj.width - 11;
//		resizeControl.y = obj.height - 11;
	}	
	
}
}