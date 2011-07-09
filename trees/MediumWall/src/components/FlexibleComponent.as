package components
{
import eventing.events.ResizeEvent;
import eventing.events.IEvent;
import components.controls.ResizeControlUIComponent;
import spark.components.WindowedApplication;
import mx.core.WindowedApplication;
import mx.core.UIComponent;
import mx.core.FlexGlobals;


// Movability + Resizability
public class FlexibleComponent extends MovableComponent implements IFlexibleComponent
{
	private var resizeControl:ResizeControlUIComponent;
	
	public function FlexibleComponent()
	{
		resizeControl = new ResizeControlUIComponent();	
		// add resize control (event)
		
		// show resize control on focus
		addFocusInEventListener(function(e:IEvent):void
		{
			try {
				FlexGlobals.topLevelApplication.addElement(resizeControl);
				
				resizeControl.width = 200;
				resizeControl.height = 200;
				resizeControl.x = 200;
				resizeControl.y = 200;
			}
			catch(e:Error)
			{
				
			}
		});
		
		addFocusOutEventListener(function(e:IEvent):void
		{
			try {
				FlexGlobals.topLevelApplication.removeElement(resizeControl);
			}
			catch(e:Error)
			{
				
			}
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