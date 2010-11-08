// Drag Functionality
import components.events.SpatialEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flashx.textLayout.elements.GlobalSettings;
import mx.core.UIComponent;


private var dragStartPos:Point;
private var dragGlobalLocalDiff:Point;

public function dragInit():void
{
	if(!this.hasEventListener(MouseEvent.MOUSE_DOWN))
		this.addEventListener(MouseEvent.MOUSE_DOWN, dragStart);
}


public function dragStart(e:MouseEvent):void
{
	e.stopPropagation();
	dragStartPos = this.parent.localToGlobal(new Point(this.x, this.y));
	dragGlobalLocalDiff = dragStartPos.subtract(new Point(e.stageX, e.stageY));
	stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
	stage.addEventListener(MouseEvent.MOUSE_UP, dragEnd);
	
	//this.dispatchEvent(new SpatialEvent(SpatialEvent.MOV, false, false, this.x, this.y));
}

public function drag(e:MouseEvent):void
{
	var current:Point = this.parent.globalToLocal((new Point(e.stageX, e.stageY)).add(dragGlobalLocalDiff));
	this.x = dragBoundx(current.x);
	this.y = dragBoundy(current.y);
	
	this.dispatchEvent(new SpatialEvent(SpatialEvent.MOVING, false, false, this.x, this.y));
}

public function dragEnd(e:MouseEvent):void
{
	var current:Point = this.parent.globalToLocal((new Point(e.stageX, e.stageY)).add(dragGlobalLocalDiff));
	this.x = dragBoundx(current.x);
	this.y = dragBoundy(current.y);
	
	stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);	
	stage.removeEventListener(MouseEvent.MOUSE_UP, dragEnd);
	
	this.dispatchEvent(new SpatialEvent(SpatialEvent.MOVED, false, false, this.x, this.y));
}


