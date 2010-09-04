// Drag Functionality
import flash.events.MouseEvent;

private var c_stageX:Number, c_stageY:Number;
private var c_x:Number, c_y:Number;

public function dragStart(e:MouseEvent):void
{
	c_x = this.x;
	c_y = this.y;
	c_stageX = e.stageX;
	c_stageY = e.stageY;
	stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
	stage.addEventListener(MouseEvent.MOUSE_UP, dragEnd);
}

public function dragEnd(e:MouseEvent):void
{
	stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);	
	stage.removeEventListener(MouseEvent.MOUSE_UP, dragEnd);
}

public function drag(e:MouseEvent):void
{
	this.x = c_x + (e.stageX - c_stageX);
	this.y = c_y + (e.stageY - c_stageY);
}