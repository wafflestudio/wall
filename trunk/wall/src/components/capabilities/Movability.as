package components.capabilities
{

import components.SpatialObject;
import components.events.SpatialEvent;

import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import flashx.textLayout.elements.GlobalSettings;

import mx.core.UIComponent;

public class Movability
{
	private var obj:SpatialObject;
	
	public function Movability(target:SpatialObject)
	{
		this.obj = target;
		moveInit();
	}
	
	private var moveStartPos:Point;
	private var moveGlobalLocalDiff:Point;
	
	public function moveInit():void
	{
		if(!obj.hasEventListener(MouseEvent.MOUSE_DOWN))
			obj.addEventListener(MouseEvent.MOUSE_DOWN, moveStart);
	}
	
	
	public function moveStart(e:MouseEvent):void
	{
		e.stopPropagation();
		moveStartPos = obj.parent.localToGlobal(new Point(obj.x, obj.y));
		moveGlobalLocalDiff = moveStartPos.subtract(new Point(e.stageX, e.stageY));
		obj.stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
		obj.stage.addEventListener(MouseEvent.MOUSE_UP, moveEnd);
	}
	
	public function move(e:MouseEvent):void
	{
		var current:Point = obj.parent.globalToLocal((new Point(e.stageX, e.stageY)).add(moveGlobalLocalDiff));
		obj.x = current.x;
		obj.y = current.y;
		
		obj.dispatchEvent(new SpatialEvent(SpatialEvent.MOVING, false, false, obj.x, obj.y));
	}
	
	public function moveEnd(e:MouseEvent):void
	{
		var current:Point = obj.parent.globalToLocal((new Point(e.stageX, e.stageY)).add(moveGlobalLocalDiff));
		obj.x = current.x;
		obj.y = current.y;
		
		obj.stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);	
		obj.stage.removeEventListener(MouseEvent.MOUSE_UP, moveEnd);
		
		obj.dispatchEvent(new SpatialEvent(SpatialEvent.MOVED, false, false, obj.x, obj.y));
	}
	
	

}
}