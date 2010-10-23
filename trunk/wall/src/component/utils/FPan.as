import component.event.PanEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.effects.Move;
import mx.effects.easing.Sine;

import spark.effects.easing.EaseInOutBase;
import spark.effects.easing.EasingFraction;



private var c_stageX:Number, c_stageY:Number;
private var c_x:Number, c_y:Number;
private var c_lshiftx:Number, c_ushiftx:Number, c_lshifty:Number, c_ushifty:Number;
// ActionScript file

public function panInit():void
{
	this.addEventListener(MouseEvent.MOUSE_DOWN, panStart);
}

public function panStart(e:MouseEvent):void
{
	c_x = childrenHolder.x;
	c_y = childrenHolder.y;
	c_stageX = e.stageX;
	c_stageY = e.stageY;
	c_lshiftx = c_ushiftx = 0;
	c_lshifty = c_ushifty = 0;
	stage.addEventListener(MouseEvent.MOUSE_MOVE, pan);
	stage.addEventListener(MouseEvent.MOUSE_UP, panEnd);
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN_START, false, false, childrenHolder.x, childrenHolder.y));
}


public function panEnd(e:MouseEvent):void
{
	childrenHolder.x = panBoundx(c_x + (e.stageX - c_stageX)); + c_lshiftx + c_ushiftx;
	childrenHolder.y = panBoundy(c_y + (e.stageY - c_stageY)); + c_lshifty + c_ushifty;
	
	stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan);	
	stage.removeEventListener(MouseEvent.MOUSE_UP, panEnd);
	
	
	var xTo:Number = childrenHolder.x;
	var yTo:Number = childrenHolder.y;
	
	if(horizontalOverflow)  {
		if(childrenHolder.x + childrenMaxX < containerWidth)  {
			xTo = containerWidth - childrenMaxX;
		}
		else if(childrenHolder.x + childrenMinX > 0){
			xTo = - (childrenMinX);
		}
	}
	else  {
		if(childrenHolder.x + childrenMaxX > containerWidth)  {
			xTo = containerWidth - childrenMaxX;
		}
		else if(childrenHolder.x + childrenMinX < 0){
			xTo = - (childrenMinX);
		}
	}
	
	if(verticalOverflow)  {
		if(childrenHolder.y + childrenMaxY < containerHeight)  {
			yTo = containerHeight - childrenMaxY;
		}
		else if(childrenHolder.y + childrenMinY > 0){
			yTo = - (childrenMinY);
		}
	}
	else  {
		if(childrenHolder.y + childrenMaxY > containerHeight)  {
			yTo = containerHeight - childrenMaxY;
		}
		else if(childrenHolder.y + childrenMinY < 0){
			yTo = - (childrenMinY);
		}
	}
	
	if(xTo != this.x || yTo != this.y)  {
		var moveeffect:Move;
		moveeffect = new Move(childrenHolder);
		moveeffect.xTo = xTo;
		moveeffect.yTo = yTo;
		moveeffect.duration = 200;
		moveeffect.easingFunction = Sine.easeOut;
		moveeffect.play();
	}
	
		
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN_END, false, false, childrenHolder.x, childrenHolder.y));
}


public function pan(e:MouseEvent):void
{
	var deltax:Number, deltay:Number;
	var x:Number = c_x + (e.stageX - c_stageX);
	var y:Number = c_y + (e.stageY - c_stageY);
	
	if(x + this.contentWidth < containerWidth)  {
		deltax = (containerWidth - (x + this.contentWidth))/3*2;
		c_ushiftx =  c_ushiftx < deltax ? deltax : c_ushiftx;
	
	}
	else if(x > 0) {
		deltax = -x / 3*2;
		c_lshiftx = deltax < c_lshiftx ? deltax: c_lshiftx;
	}
	
	if(y + this.contentHeight < containerHeight)  {
		deltay = (containerHeight - (y + this.contentHeight))/3*2;
		c_ushifty =  c_ushifty < deltay ? deltay : c_ushifty;
		
	}
	else if(y > 0){
		deltay = -y / 3*2;
		c_lshifty = deltay < c_lshifty ? deltay: c_lshifty;
	}
	
	childrenHolder.x = panBoundx(c_x + (e.stageX - c_stageX)); + c_lshiftx + c_ushiftx;
	childrenHolder.y = panBoundy(c_y + (e.stageY - c_stageY)); + c_lshifty + c_ushifty;
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN, false, false, childrenHolder.x, childrenHolder.y));
}