package components.capabilities
{
import components.SpatialObject;
import components.controls.HorizontalScrollbar;
import components.controls.ScrollbarBase;
import components.controls.VerticalScrollbar;
import components.events.ChildrenEvent;
import components.events.PanEvent;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import spark.components.Group;

public class Pannability
{
	private var target:SpatialObject;
	private var childrenContainer:Group;
	
	private var horizontalScrollbar:HorizontalScrollbar;
	private var verticalScrolbar:VerticalScrollbar;
	
	public function Pannability(target:SpatialObject, childrenContainer:Group)
	{
		this.target = target;
		this.childrenContainer = childrenContainer;
		horizontalScrollbar = new HorizontalScrollbar(target);
		verticalScrolbar = new VerticalScrollbar(target);
		
		panInit();
	}	
	
	private function panInit():void
	{
		target.addEventListener(MouseEvent.MOUSE_DOWN, panStart);
	}
	
	private var deltaX:Number;
	private var deltaY:Number;
	
	private function panStart(e:MouseEvent):void  {
		target.stage.addEventListener(MouseEvent.MOUSE_MOVE, pan);
		target.stage.addEventListener(MouseEvent.MOUSE_UP, panEnd);
		
		deltaX = childrenContainer.x - e.localX;
		deltaY = childrenContainer.y - e.localY;
		
	}
	
	private function pan(e:MouseEvent):void  {		
		childrenContainer.x = deltaX + e.localX;
		childrenContainer.y = deltaY + e.localY;
		target.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE, false, false));
	}
	
	private function panEnd(e:MouseEvent):void  {		
		childrenContainer.x = deltaX + e.localX;
		childrenContainer.y = deltaY + e.localY;
		
		target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan);
		target.stage.removeEventListener(MouseEvent.MOUSE_UP, panEnd);
		target.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE, false, false));
	}



}
}