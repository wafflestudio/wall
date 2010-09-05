// Drag Functionality
import component.event.DragEvent;

import flash.events.Event;
import flash.events.MouseEvent;

private var c_stageX:Number, c_stageY:Number;
private var c_x:Number, c_y:Number;

public function dragInit():void
{
	if(!this.hasEventListener(MouseEvent.MOUSE_DOWN))
		this.addEventListener(MouseEvent.MOUSE_DOWN, dragStart);
}

public function dragStart(e:MouseEvent):void
{
	c_x = this.x;
	c_y = this.y;
	c_stageX = e.stageX;
	c_stageY = e.stageY;
	stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
	stage.addEventListener(MouseEvent.MOUSE_UP, dragEnd);
	
	this.dispatchEvent(new DragEvent(DragEvent.DRAG_START, false, false, this.x, this.y));
}

public function dragEnd(e:MouseEvent):void
{
	this.x = c_x + (e.stageX - c_stageX);
	this.y = c_y + (e.stageY - c_stageY);
	
	stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);	
	stage.removeEventListener(MouseEvent.MOUSE_UP, dragEnd);
	
	this.dispatchEvent(new DragEvent(DragEvent.DRAG_END, false, false, this.x, this.y));
}

public function drag(e:MouseEvent):void
{
	this.x = c_x + (e.stageX - c_stageX);
	this.y = c_y + (e.stageY - c_stageY);
	
	this.dispatchEvent(new DragEvent(DragEvent.DRAG, false, false, this.x, this.y));
}