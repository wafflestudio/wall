
import components.controls.ScrollbarBase;
import components.events.PanEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import spark.effects.Fade;
import spark.effects.Move;
import spark.effects.Resize;
import spark.effects.SetAction;
import spark.effects.easing.EaseInOutBase;
import spark.effects.easing.EasingFraction;
import spark.effects.easing.Sine;

private var horizontalScrollbar:ScrollbarBase = new ScrollbarBase();
private var verticalScrollbar:ScrollbarBase = new ScrollbarBase();

private var c_stageX:Number, c_stageY:Number;
private var c_x:Number, c_y:Number;
private var c_lshiftx:Number, c_ushiftx:Number, c_lshifty:Number, c_ushifty:Number;


public function panInit():void
{
	this.addEventListener(MouseEvent.MOUSE_DOWN, panStart);
	this.addElement(horizontalScrollbar);
	this.addElement(verticalScrollbar);
	horizontalScrollbar.height = 5;
	verticalScrollbar.width = 5;
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
	horizontalScrollbar.y = containerHeight-7;
	verticalScrollbar.x = containerWidth-7;
	if(horizontalOverflow)
		horizontalScrollbar.show();
	if(verticalOverflow)
		verticalScrollbar.show();
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN_START, false, false, childrenHolder.x, childrenHolder.y));
}

public function pan(e:MouseEvent):void
{
	var deltax:Number, deltay:Number;
	var x:Number = c_x + (e.stageX - c_stageX);
	var y:Number = c_y + (e.stageY - c_stageY);
	
	if(horizontalOverflow)  {
		if(x + childrenMinX*childrenHolder.scaleX + contentWidth < containerWidth)  {
			deltax = (containerWidth - (x + childrenMinX*childrenHolder.scaleX + contentWidth))/3*2;
			c_ushiftx =  c_ushiftx < deltax ? deltax : c_ushiftx;
		}   
		else if(x + childrenMinX*childrenHolder.scaleX > 0) {
			deltax = -(x + childrenMinX*childrenHolder.scaleX) / 3*2;
			c_lshiftx = deltax < c_lshiftx ? deltax: c_lshiftx;
		}
	}
	
	
	if(verticalOverflow)  {
		if(y + childrenMinY*childrenHolder.scaleY + contentHeight < containerHeight)  {
			deltay = (containerHeight - (y + childrenMinY*childrenHolder.scaleY + contentHeight))/3*2;
			c_ushifty =  c_ushifty < deltay ? deltay : c_ushifty;
			
		}
		else if(y + childrenMinY*childrenHolder.scaleY > 0){
			deltay = -(y+childrenMinY*childrenHolder.scaleY) / 3*2;
			c_lshifty = deltay < c_lshifty ? deltay: c_lshifty;
		}
	}
	
	childrenHolder.x = (c_x + (e.stageX - c_stageX)) + c_lshiftx + c_ushiftx;
	childrenHolder.y = (c_y + (e.stageY - c_stageY)) + c_lshifty + c_ushifty;
	
	var width:Number = (childrenMaxX - childrenMinX)*childrenHolder.scaleX + 
		(childrenHolder.x + childrenMinX*childrenHolder.scaleX > 0 ? childrenHolder.x + childrenMinX*childrenHolder.scaleX : 0) +
		(childrenHolder.x + childrenMaxX*childrenHolder.scaleX < containerWidth ? containerWidth - (childrenHolder.x+childrenMaxX*childrenHolder.scaleX) : 0);
	var posX:Number = (childrenHolder.x + childrenMinX*childrenHolder.scaleX) > 0 ? 0:
		-(childrenHolder.x + childrenMinX*childrenHolder.scaleX);
	
	var height:Number = (childrenMaxY - childrenMinY)*childrenHolder.scaleY + 
		(childrenHolder.y + childrenMinY*childrenHolder.scaleY > 0 ? childrenHolder.y + childrenMinY*childrenHolder.scaleY : 0) +
		(childrenHolder.y + childrenMaxY*childrenHolder.scaleY < containerHeight ? containerHeight - (childrenHolder.y+childrenMaxY*childrenHolder.scaleY) : 0);
	var posY:Number = (childrenHolder.y + childrenMinY*childrenHolder.scaleY) > 0 ? 0:
		-(childrenHolder.y + childrenMinY*childrenHolder.scaleY);
	
	
	horizontalScrollbar.width = (containerWidth-10)*containerWidth/width;
	horizontalScrollbar.x = posX / width * (containerWidth-10)
	
	verticalScrollbar.height = (containerHeight-10)*containerHeight/height;
	verticalScrollbar.y = posY / height * (containerHeight-10);
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN, false, false, childrenHolder.x, childrenHolder.y));
}

public function panEnd(e:MouseEvent):void
{
	childrenHolder.x = (c_x + (e.stageX - c_stageX)) + c_lshiftx + c_ushiftx;
	childrenHolder.y = (c_y + (e.stageY - c_stageY)) + c_lshifty + c_ushifty;
	
	stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan);	
	stage.removeEventListener(MouseEvent.MOUSE_UP, panEnd);
	
	var xTo:Number = childrenHolder.x;
	var yTo:Number = childrenHolder.y;
	
	if(horizontalOverflow)  {
		if(childrenHolder.x + childrenMaxX*childrenHolder.scaleX < containerWidth)  {
			xTo = containerWidth - childrenMaxX*childrenHolder.scaleX;
		}
		else if(childrenHolder.x + childrenMinX*childrenHolder.scaleX > 0){
			xTo = - (childrenMinX*childrenHolder.scaleX);
		}
	}
	else  {
		if(childrenHolder.x + childrenMaxX*childrenHolder.scaleX > containerWidth)  {
			xTo = containerWidth - childrenMaxX*childrenHolder.scaleX;
		}
		else if(childrenHolder.x + childrenMinX*childrenHolder.scaleX < 0){
			xTo = - (childrenMinX*childrenHolder.scaleX);
		}
	}
	
	if(verticalOverflow)  {
		if(childrenHolder.y + childrenMaxY*childrenHolder.scaleY < containerHeight)  {
			yTo = containerHeight - childrenMaxY*childrenHolder.scaleY;
		}
		else if(childrenHolder.y + childrenMinY*childrenHolder.scaleY > 0){
			yTo = - (childrenMinY*childrenHolder.scaleY);
		}
	}
	else  {
		if(childrenHolder.y + childrenMaxY*childrenHolder.scaleY > containerHeight)  {
			yTo = containerHeight - childrenMaxY*childrenHolder.scaleY;
		}
		else if(childrenHolder.y + childrenMinY*childrenHolder.scaleY < 0){
			yTo = - (childrenMinY*childrenHolder.scaleY);
		}
	}
	
	
	if(xTo != childrenHolder.x || yTo != childrenHolder.y)  {
		var moveeffect:Move;
		moveeffect = new Move(childrenHolder);
		moveeffect.xTo = xTo;
		moveeffect.yTo = yTo;
		moveeffect.duration = 200;
		moveeffect.easer = new Sine();
		moveeffect.play();
		
		var width:Number = (childrenMaxX - childrenMinX)*childrenHolder.scaleX + 
			(xTo + childrenMinX*childrenHolder.scaleX > 0 ? xTo + childrenMinX*childrenHolder.scaleX : 0) +
			(xTo + childrenMaxX*childrenHolder.scaleX < containerWidth ? containerWidth - (xTo+childrenMaxX*childrenHolder.scaleX) : 0);
		var posX:Number = (xTo + childrenMinX*childrenHolder.scaleX) > 0 ? 0:
			-(xTo + childrenMinX*childrenHolder.scaleX);
		
		var height:Number = (childrenMaxY - childrenMinY)*childrenHolder.scaleY + 
			(yTo + childrenMinY*childrenHolder.scaleY > 0 ? yTo + childrenMinY*childrenHolder.scaleY : 0) +
			(yTo + childrenMaxY*childrenHolder.scaleY < containerHeight ? containerHeight - (yTo+childrenMaxY*childrenHolder.scaleY) : 0);
		var posY:Number = (yTo + childrenMinY*childrenHolder.scaleY) > 0 ? 0:
			-(yTo + childrenMinY*childrenHolder.scaleY);
		
		var hmoveeffect:Move = new Move(horizontalScrollbar);
		hmoveeffect.xTo = posX / width * (containerWidth-10);
		hmoveeffect.duration = 200;
		hmoveeffect.easer = new Sine();
		hmoveeffect.play();
		
		var vmoveeffect:Move = new Move(verticalScrollbar);
		vmoveeffect.yTo = posY / height * (containerHeight-10);
		vmoveeffect.duration = 200;
		vmoveeffect.easer = new Sine();
		vmoveeffect.play();
		
		var swidtheffect:Resize = new Resize(horizontalScrollbar);
		swidtheffect.widthTo = (containerWidth-10)*containerWidth/width;
		swidtheffect.duration = 200;
		swidtheffect.easer = new Sine();
		swidtheffect.play();
		
		var sheighteffect:Resize = new Resize(verticalScrollbar);
		sheighteffect.heightTo = (containerHeight-10)*containerHeight/height;
		sheighteffect.duration = 200;
		sheighteffect.easer = new Sine();
		sheighteffect.play();
		
		horizontalScrollbar.hide();
		verticalScrollbar.hide();
	}
	
	
	
	this.dispatchEvent(new PanEvent(PanEvent.PAN_END, false, false, childrenHolder.x, childrenHolder.y));
}

