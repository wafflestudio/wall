package behaviors.capabilities
{
import components.SpatialObject;
import components.controls.HorizontalScrollbar;
import components.controls.ScrollbarBase;
import components.controls.VerticalScrollbar;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import spark.components.Group;
import behaviors.events.ChildrenEvent;

public class Pannability
{
	private var target:SpatialObject;
	private var childrenContainer:Group;
	
	private var horizontalScrollbar:HorizontalScrollbar;
	private var verticalScrolbar:VerticalScrollbar;
	
	private var panStartPos:Point;
	private var panGlobalLocalDiff:Point;
	
	
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
	
	
	private function panStart(e:MouseEvent):void  {
//		if(e.target != e.currentTarget)
//			return;
		
		target.stage.addEventListener(MouseEvent.MOUSE_MOVE, pan);
		target.stage.addEventListener(MouseEvent.MOUSE_UP, panEnd);
		
		panStartPos = target.localToGlobal(new Point(childrenContainer.x, childrenContainer.y));
		panGlobalLocalDiff = panStartPos.subtract(new Point(e.stageX, e.stageY));
	}
	
	private function pan(e:MouseEvent):void  {	
		var current:Point = target.globalToLocal((new Point(e.stageX, e.stageY)).add(panGlobalLocalDiff));
		childrenContainer.x = current.x;
		childrenContainer.y = current.y;

		target.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE, false, false));
	}
	
	private function panEnd(e:MouseEvent):void  {	
		var current:Point = target.globalToLocal((new Point(e.stageX, e.stageY)).add(panGlobalLocalDiff));
		childrenContainer.x = current.x;
		childrenContainer.y = current.y;

		target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan);
		target.stage.removeEventListener(MouseEvent.MOUSE_UP, panEnd);
		target.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE, false, false));
	}



}
}