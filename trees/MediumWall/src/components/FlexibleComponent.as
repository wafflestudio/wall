package components
{
import eventing.events.ResizeEvent;
import components.controls.ResizeControlUIComponent;
import spark.components.WindowedApplication;
import mx.core.WindowedApplication;
import mx.core.UIComponent;
import mx.core.FlexGlobals;
import flash.geom.Point;
import spark.components.Application;
import components.controls.ResizeControl;
import eventing.events.FocusEvent;
import eventing.events.MoveEvent;



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
			if(resizeControl.isActive)
				return;
			
			resizeControl.addToApplication(FlexGlobals.topLevelApplication as Application);
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
				resizeControl.removeFromApplication(FlexGlobals.topLevelApplication as Application);
			
		});
		
		addMovingEventListener(function(e:MoveEvent):void
		{
			if(resizeControl.isActive)
				resizeControl.removeFromApplication(FlexGlobals.topLevelApplication as Application);
			
		});
		
		addMovedEventListener(function(e:MoveEvent):void
		{
			if(resizeControl.isActive)  
				return;
			
			resizeControl.addToApplication(FlexGlobals.topLevelApplication as Application);
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
			var upperLeft:Point = (parent as Component).globalToLocal((FlexGlobals.topLevelApplication as Application).localToGlobal(new Point(e.left, e.top)));
			var lowerRight:Point = (parent as Component).globalToLocal((FlexGlobals.topLevelApplication as Application).localToGlobal(new Point(e.right, e.bottom)));
			x = upperLeft.x;
			y = upperLeft.y;
			
			var diff:Point = lowerRight.subtract(upperLeft);
			width = diff.x;
			height = diff.y;
			trace(x, y, width, height);
		});
		
		resizeControl.addResizedEventListener(function(e:ResizeEvent):void 
		{
			
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
	
	protected function dispatchResizingEvent(left:Number, top:Number, right:Number, bottom:Number):void
	{
		dispatchEvent(new ResizeEvent(this, ResizeEvent.RESIZING, left, top, right, bottom));
	}
	
	protected function dispatchResizedEvent(left:Number, top:Number, right:Number, bottom:Number):void
	{
		dispatchEvent(new ResizeEvent(this, ResizeEvent.RESIZED, left, top, right, bottom));
	}
}
}