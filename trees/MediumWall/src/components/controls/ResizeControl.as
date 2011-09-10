package components.controls
{
import eventing.eventdispatchers.IResizeEventDispatcher;
import eventing.events.ResizeEvent;

import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;

import spark.components.Application;

public class ResizeControl extends Control implements IResizeEventDispatcher
{
	private var resizeUIComponent:ResizeControlUIComponent;
	private var upperLeft:UIComponent = new UIComponent();
	private var upperRight:UIComponent = new UIComponent();
	private var lowerLeft:UIComponent = new UIComponent();
	private var lowerRight:UIComponent = new UIComponent();
	private var up:UIComponent = new UIComponent();
	private var left:UIComponent = new UIComponent();
	private var right:UIComponent = new UIComponent();
	private var down:UIComponent = new UIComponent();
	
	override protected function get visualElement():IVisualElement { return resizeUIComponent; }
	override protected function get visualElementContainer():IVisualElementContainer { return null; }
	
	public function ResizeControl()
	{
		super();
		resizeUIComponent = new ResizeControlUIComponent();
		
		visualElement = resizeUIComponent;
		visualElementContainer = null;
		
		var arr:Array = [up, right, left, down, upperLeft, upperRight, lowerLeft, lowerRight];
		
		var startResize:Function = function(e:MouseEvent):void
		{
			var app:Application = (resizeUIComponent.parentApplication as Application);
			var initialMouseDownPos:Point = app.globalToLocal(new Point(e.stageX, e.stageY));
			var oldX:Number = x;
			var oldY:Number = y;
			var oldWidth:Number = width;
			var oldHeight:Number = height;
			var control:UIComponent = e.currentTarget as UIComponent;
	
			function drag(e:MouseEvent):void
			{
				var curMousePos:Point = app.globalToLocal(new Point(e.stageX, e.stageY));
				var diff:Point = curMousePos.subtract(initialMouseDownPos);
				switch(control)  {
					case up:
						y = oldY + diff.y;
						height = oldHeight - diff.y;
						break;
					case down:
						height = oldHeight + diff.y;
						break;
					case left:
						x = oldX + diff.x;
						width = oldWidth - diff.x;
						break;
					case right:
						width = oldWidth + diff.x;
						break;
					case upperLeft:
						x = oldX + diff.x;
						y = oldY + diff.y;
						width = oldWidth - diff.x;
						height = oldHeight - diff.y;
						break;
					case upperRight:
						y = oldY + diff.y;
						height = oldHeight - diff.y;
						width = oldWidth + diff.x;
						break;
					case lowerLeft:
						x = oldX + diff.x;
						width = oldWidth - diff.x;
						height = oldHeight + diff.y;
						break;
					case lowerRight:
						width = oldWidth + diff.x;
						height = oldHeight + diff.y;
						break;
				}
				
				dispatchResizingEvent(oldX, oldY, oldX+oldWidth, oldY+oldHeight, x, y, x+width, y+height);
			}
			
			function endResize(e:MouseEvent):void
			{
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, drag );
				stage.removeEventListener( MouseEvent.MOUSE_UP, endResize );
				dispatchResizedEvent(oldX, oldY, oldX+oldWidth, oldY+oldHeight, x, y, x+width, y+height);
			}
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, drag );
			stage.addEventListener( MouseEvent.MOUSE_UP, endResize );
			
		};
		
		for each(var ui:UIComponent in arr)  {
			resizeUIComponent.addChild(ui);
			ui.graphics.beginFill(0);
			ui.graphics.drawCircle(0, 0, 5);
			ui.graphics.endFill();
			ui.addEventListener(MouseEvent.MOUSE_DOWN, startResize); 
		}
	
		
		
	}
	
	override public function set width(val:Number):void
	{
		super.width = val;
		upperRight.x = val;
		lowerRight.x = val;
		right.x = val;
		up.x = val/2;
		down.x = val/2;
		
	}
	
	override public function set height(val:Number):void
	{
		super.height = val;
		lowerLeft.y = val;
		lowerRight.y = val;
		down.y = val;
		left.y = val/2;
		right.y = val/2;
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