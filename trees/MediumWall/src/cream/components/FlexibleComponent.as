package cream.components
{
import cream.components.controls.ResizeControl;
import cream.components.controls.ResizeControlUIComponent;

import cream.eventing.events.FocusEvent;
import cream.eventing.events.MoveEvent;
import cream.eventing.events.ResizeEvent;

import flash.geom.Point;

import mx.core.UIComponent;

import spark.components.Application;



// Movability + Resizability
public class FlexibleComponent extends MovableComponent implements IFlexibleComponent
{
	private var resizeControl:ResizeControl;
	
	public function FlexibleComponent()
	{
		resizeControl = new ResizeControl();	
		// add resize control (event)
		
		// show resize control on focus
		addFocusInEventListener(function(e:FocusEvent):void
		{
			if(!resizeControl.isActive)
				resizeControl.addToApplication(application);
			
			var wh:Point = new Point(width,height);
			var xy:Point = new Point(x,y);
			resizeControl.width = (parent as Component).localToGlobal(new Point(x+width,0)).x - (parent as Component).localToGlobal(xy).x;
			resizeControl.height = (parent as Component).localToGlobal(new Point(0,y+height)).y - (parent as Component).localToGlobal(xy).y;
			resizeControl.x = (parent as Component).localToGlobal(xy).x;
			resizeControl.y = (parent as Component).localToGlobal(xy).y;
			
		});
		
		addFocusOutEventListener(function(e:FocusEvent):void
		{
			if(resizeControl.isActive)
				resizeControl.removeFromApplication(application);
			
		});
		
		addMovingEventListener(function(e:MoveEvent):void
		{
			if(resizeControl.isActive)
				resizeControl.removeFromApplication(application);
			
		});
		
		addMovedEventListener(function(e:MoveEvent):void
		{
			if(resizeControl.isActive)  
				return;
			
			resizeControl.addToApplication(application);
			var wh:Point = new Point(width,height);
			var xy:Point = new Point(x,y);
			resizeControl.width = (parent as Component).localToGlobal(new Point(x+width,0)).x - (parent as Component).localToGlobal(xy).x;
			resizeControl.height = (parent as Component).localToGlobal(new Point(0,y+height)).y - (parent as Component).localToGlobal(xy).y;
			resizeControl.x = (parent as Component).localToGlobal(xy).x;
			resizeControl.y = (parent as Component).localToGlobal(xy).y;
			
		});
		
		addExternalDimensionChangeEventListener(function():void
		{
			if(resizeControl.isActive)
			{
				var wh:Point = new Point(width,height);
				var xy:Point = new Point(x,y);
				resizeControl.width = (parent as Component).localToGlobal(new Point(x+width,0)).x - (parent as Component).localToGlobal(xy).x;
				resizeControl.height = (parent as Component).localToGlobal(new Point(0,y+height)).y - (parent as Component).localToGlobal(xy).y;
				resizeControl.x = (parent as Component).localToGlobal(xy).x;
				resizeControl.y = (parent as Component).localToGlobal(xy).y;
			}
		});
		
		resizeControl.addResizingEventListener(function(e:ResizeEvent):void 
		{
			var upperLeft:Point = (parent as Component).globalToLocal(application.localToGlobal(new Point(e.left, e.top)));
			var lowerRight:Point = (parent as Component).globalToLocal(application.localToGlobal(new Point(e.right, e.bottom)));
			x = upperLeft.x;
			y = upperLeft.y;
			
			var diff:Point = lowerRight.subtract(upperLeft);
			width = diff.x;
			height = diff.y;
		});
		
		resizeControl.addResizedEventListener(function(e:ResizeEvent):void 
		{
			var oldUpperLeft:Point = (parent as Component).globalToLocal(application.localToGlobal(new Point(e.oldLeft, e.oldTop)));
			var oldLowerRight:Point = (parent as Component).globalToLocal(application.localToGlobal(new Point(e.oldRight, e.oldBottom)));
			
			var upperLeft:Point = (parent as Component).globalToLocal(application.localToGlobal(new Point(e.left, e.top)));
			var lowerRight:Point = (parent as Component).globalToLocal(application.localToGlobal(new Point(e.right, e.bottom)));
			
			
			var oldX:Number = oldUpperLeft.x;
			var oldY:Number = oldUpperLeft.y;
			var oldDiff:Point = oldLowerRight.subtract(oldUpperLeft);
			var oldWidth:Number = oldDiff.x;
			var oldHeight:Number = oldDiff.y;
			x = upperLeft.x;
			y = upperLeft.y;
			
			var diff:Point = lowerRight.subtract(upperLeft);
			width = diff.x;
			height = diff.y;
			
			dispatchResizedEvent(oldX, oldY, oldX+oldWidth, oldY+oldHeight, x, y, x+width, y+height);
		});
	}
	
	public function addResizingEventListener(listener:Function):void
	{
		addEventListener(ResizeEvent.RESIZING, listener);
	}
	
	public function removeResizingEventListener(listener:Function):void
	{
		removeEventListener(ResizeEvent.RESIZING, listener);	
	}
	
	
	public function addResizedEventListener(listener:Function):void
	{
		addEventListener(ResizeEvent.RESIZED, listener);
	}
	
	public function removeResizedEventListener(listener:Function):void
	{
		removeEventListener(ResizeEvent.RESIZED, listener);
	}
	
	protected function dispatchResizingEvent(oldLeft:Number, oldTop:Number, oldRight:Number, oldBottom:Number,
											 left:Number, top:Number, right:Number, bottom:Number):void
	{
		dispatchEvent(new ResizeEvent(this, ResizeEvent.RESIZING, oldLeft, oldTop, oldRight, oldBottom,
			left, top, right, bottom));
	}
	
	protected function dispatchResizedEvent(oldLeft:Number, oldTop:Number, oldRight:Number, oldBottom:Number,
											left:Number, top:Number, right:Number, bottom:Number):void
	{
		dispatchEvent(new ResizeEvent(this, ResizeEvent.RESIZED, oldLeft, oldTop, oldRight, oldBottom,
			left, top, right, bottom));
	}
}
}