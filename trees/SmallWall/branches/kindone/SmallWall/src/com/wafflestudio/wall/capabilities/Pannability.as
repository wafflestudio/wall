package com.wafflestudio.wall.capabilities
{
import com.wafflestudio.wall.components.elements.WallComponent;
import com.wafflestudio.wall.components.controls.HorizontalScrollbar;
import com.wafflestudio.wall.components.controls.ScrollbarBase;
import com.wafflestudio.wall.components.controls.VerticalScrollbar;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import spark.components.Group;
import com.wafflestudio.wall.events.ChildrenEvent;

public class Pannability
{
	private var target:WallComponent;
	
	
	private var horizontalScrollbar:HorizontalScrollbar;
	private var verticalScrolbar:VerticalScrollbar;
	
	private var panStartPos:Point;
	private var panGlobalLocalDiff:Point;
	
	
	public function Pannability(target:WallComponent)
	{
		this.target = target;
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
		
		panStartPos = target.localToGlobal(new Point(target.panX, target.panY));
		panGlobalLocalDiff = panStartPos.subtract(new Point(e.stageX, e.stageY));
	}
	
	private function pan(e:MouseEvent):void  {	
		var current:Point = target.globalToLocal((new Point(e.stageX, e.stageY)).add(panGlobalLocalDiff));
		target.panX = current.x;
		target.panY = current.y;

		target.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE, false, false));
	}
	
	private function panEnd(e:MouseEvent):void  {	
		var current:Point = target.globalToLocal((new Point(e.stageX, e.stageY)).add(panGlobalLocalDiff));
		target.panX = current.x;
		target.panY = current.y;

		target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan);
		target.stage.removeEventListener(MouseEvent.MOUSE_UP, panEnd);
		target.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE, false, false));
	}



}
}