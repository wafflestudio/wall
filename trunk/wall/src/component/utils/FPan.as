import flash.events.MouseEvent;
import component.event.PanEvent;
import flash.events.Event;



private var c_stageX:Number, c_stageY:Number;
private var c_x:Number, c_y:Number;
// ActionScript file

public function panInit():void
{
	if(!this.hasEventListener(MouseEvent.MOUSE_DOWN))
		this.addEventListener(MouseEvent.MOUSE_DOWN, panStart);
}

public function panStart(e:MouseEvent):void
{
	c_x = this.x;
	c_y = this.y;
	c_stageX = e.stageX;
	c_stageY = e.stageY;
	stage.addEventListener(MouseEvent.MOUSE_MOVE, pan);
	stage.addEventListener(MouseEvent.MOUSE_UP, panEnd);
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN_START, false, false, this.x, this.y));
}


public function panEnd(e:MouseEvent):void
{
	this.x = panBoundx(c_x + (e.stageX - c_stageX));
	this.y = panBoundy(c_y + (e.stageY - c_stageY));
	
	stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan);	
	stage.removeEventListener(MouseEvent.MOUSE_UP, panEnd);
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN_END, false, false, this.x, this.y));
}


public function pan(e:MouseEvent):void
{
	this.x = panBoundx(c_x + (e.stageX - c_stageX));
	this.y = panBoundy(c_y + (e.stageY - c_stageY));
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN, false, false, this.x, this.y));
}