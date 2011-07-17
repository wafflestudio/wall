package components
{
import eventing.events.ResizeEvent;
import eventing.events.IEvent;
import components.controls.ResizeControlUIComponent;
import spark.components.WindowedApplication;
import mx.core.WindowedApplication;
import mx.core.UIComponent;
import mx.core.FlexGlobals;
import flash.geom.Point;
import spark.components.Application;
import components.controls.ResizeControl;



// Movability + Resizability
public class FlexibleComponent extends MovableComponent implements IFlexibleComponent
{
	private var resizeControl:ResizeControl;
	
	public function FlexibleComponent()
	{
		resizeControl = new ResizeControl();	
		// add resize control (event)
		
		// show resize control on focus
		addFocusInEventListener(function(e:IEvent):void
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
		
		addFocusOutEventListener(function(e:IEvent):void
		{
			if(resizeControl.isActive)
				resizeControl.removeFromApplication(FlexGlobals.topLevelApplication as Application);
			
		});
		
		addMovingEventListener(function(e:IEvent):void
		{
			if(resizeControl.isActive)
				resizeControl.removeFromApplication(FlexGlobals.topLevelApplication as Application);
			
		});
		
		addMovedEventListener(function(e:IEvent):void
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