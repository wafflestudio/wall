package components
{
import eventing.events.DimensionChangeEvent;
import eventing.events.Event;
import eventing.events.ExternalDimensionChangeEvent;
import eventing.events.FocusEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.errors.IllegalOperationError;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.sampler.StackFrame;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;

import spark.components.Application;
import spark.components.Button;
import spark.components.Group;
import spark.core.IGraphicElement;

public class Component extends Composite implements IComponent
{
	protected namespace _ = "http://cream.wafflestudio.com";	
	
	private var _visualElement:IVisualElement;
	private var _visualElementContainer:IVisualElementContainer;
	private var _hasFocus:Boolean = false;
	
	protected function get visualElement():IVisualElement {  return _visualElement;  }
	protected function set visualElement(val:IVisualElement):void {  _visualElement = val;  }
	protected function get visualElementContainer():IVisualElementContainer	{  return _visualElementContainer;	}
	protected function set visualElementContainer(val:IVisualElementContainer):void {  _visualElementContainer = val; }
	protected function get parentComponent():IComponent { return parent as IComponent; }
	
	public function Component()
	{
		super();
		addDimensionChangeEventListener( function(e:Event):void {
			for each(var child:Composite in children)
			{
				(child as Component).dispatchExternalDimensionChangeEvent();
			}
		});
		
		addFocusInEventListener( function(e:FocusEvent):void {
			if(parent)
				(parent as Component).dispatchFocusInEvent();
		});
		
		addFocusOutEventListener( function(e:FocusEvent):void {
			for each(var child:Composite in children)
			{
				(child as Component).dispatchFocusOutEvent();
			}
		});
	
	}
	
	
	
	public function get x():Number  { return visualElement.x; }
	public function get y():Number  { return visualElement.y; }
	
	public function get width():Number { return visualElement.width; }
	public function get height():Number { return visualElement.height; }
	public function set width(val:Number):void { visualElement.width = val; }
	public function set height(val:Number):void { visualElement.height = val; }
	
	public function get percentWidth():Number { return visualElement.percentWidth; }
	public function get percentHeight():Number { return visualElement.percentWidth; }
	public function set percentWidth(val:Number):void { visualElement.percentWidth = val; }
	public function set percentHeight(val:Number):void { visualElement.percentWidth = val; }
	
	public function resize(w:Number, h:Number):void
	{
		width = w;
		height = h;
		dispatchDimensionChangeEvent(new Rectangle(x, y, width, height), new Rectangle(x, y, w, h));
	}
	
	// focus-out all siblings
	private function onChildFocusIn(e:FocusEvent):void
	{
		for each(var child:Component in children)
		{
			if(e.target != child)
				child.dispatchFocusOutEvent();
		}
	}
	
	override protected function addChild(child:Composite):Composite
	{
		var vchild:Component = child as Component;
		if(vchild == null)  {
			new Error("child must be a component");
			return null;
		}
		
		addChildTo(visualElementContainer, vchild);
		super.addChild(child);
		
		vchild.addFocusInEventListener( onChildFocusIn );
		
		return child;
	}
	
	override protected function removeChild(child:Composite):Composite
	{
		var vchild:Component = child as Component;
		if(vchild == null)  {
			new Error("child must be a component");
			return null;
		}
		
		vchild.removeFocusInEventListener( onChildFocusIn );
		
		removeChildFrom(visualElementContainer, vchild);
		
		return super.removeChild(child);
	}
	
	override protected function removeAllChildren():void
	{
		for(var i:int = numChildren-1; i >=0; i --)
		{
			var child:Component = children.removeItemAt(i) as Component;
			child.parent = null;
			removeChildFrom(visualElementContainer, child);
		}
		
	}
	
	public function addFocusInEventListener(listener:Function):void
	{
		addEventListener(FocusEvent.FOCUS_IN, listener);	
	}
	
	public function removeFocusInEventListener(listener:Function):void
	{
		removeEventListener(FocusEvent.FOCUS_IN, listener);
	}
	
	public function addFocusOutEventListener(listener:Function):void
	{
		addEventListener(FocusEvent.FOCUS_OUT, listener);
	}
	
	public function removeFocusOutEventListener(listener:Function):void
	{
		removeEventListener(FocusEvent.FOCUS_OUT, listener);	
	}
	
	
	
	public function addDimensionChangeEventListener(listener:Function):void
	{
		addEventListener(DimensionChangeEvent.DIMENSION_CHANGE, listener);
	}
	
	public function removeDimensionChangeEventListener(listener:Function):void
	{
		removeEventListener(DimensionChangeEvent.DIMENSION_CHANGE, listener);
	}
	

	
	
	public function addExternalDimensionChangeEventListener(listener:Function):void
	{
		addEventListener(ExternalDimensionChangeEvent.EXTERNAL_DIMENSION_CHANGE, listener);
	}
	
	public function removeExternalDimensionChangeEventListener(listener:Function):void
	{
		removeEventListener(ExternalDimensionChangeEvent.EXTERNAL_DIMENSION_CHANGE, listener);
	}
	

	protected function dispatchFocusInEvent():void
	{
		_hasFocus = true;
		dispatchEvent(new FocusEvent(this, FocusEvent.FOCUS_IN));
	}
	
	protected function dispatchFocusOutEvent():void
	{
		_hasFocus = false;
		dispatchEvent(new FocusEvent(this, FocusEvent.FOCUS_OUT));
	}
		
	
	protected function dispatchDimensionChangeEvent(oldRect:Rectangle, newRect:Rectangle):void
	{
		dispatchEvent(new DimensionChangeEvent(this, oldRect, newRect));
	}
	
	protected function dispatchExternalDimensionChangeEvent():void
	{
		dispatchEvent(new ExternalDimensionChangeEvent(this));
	}
	
	
	
	// helper function to keep visualElementContainer unexposed
	protected function addChildTo(visualElementContainer:IVisualElementContainer, component:IComponent):void
	{
		visualElementContainer.addElement((component as Component).visualElement);	
	}
	
	protected function removeChildFrom(visualElementContainer:IVisualElementContainer, component:Component):void
	{
		visualElementContainer.removeElement((component as Component).visualElement);
	}
	
	_ function get visualElement():IVisualElement  { return visualElement; }
	_ function get visualElementContainer():IVisualElementContainer  { return visualElementContainer; }
	
	protected function setChildIndex(component:Component, index:int):void
	{
		visualElementContainer.setElementIndex(component.visualElement, index);	
	}
	
	protected function get stage():Stage
	{
		return (visualElement as DisplayObject).stage;
	}
	
	protected function get root():ToplevelComponent
	{
		var root:ToplevelComponent;
		for(var node:Component = parent as Component; node.parent != null; node = node.parent as Component)
		{
			root = node as ToplevelComponent;	
		}
		return root;
	}
	
	protected function dispatchComponentFocusInEvent(component:Component):void
	{
		component.dispatchFocusInEvent();
	}
	
	protected function dispatchComponentFocusOutEvent(component:Component):void
	{
		component.dispatchFocusOutEvent();
	}

	public function get hasFocus():Boolean
	{
		return _hasFocus;
	}
	
	
	public function globalToLocal(point:Point):Point
	{
		return (visualElementContainer as DisplayObject).globalToLocal(point);
	}
	
	public function localToGlobal(point:Point):Point
	{	
		if(visualElementContainer)
			return (visualElementContainer as DisplayObject).localToGlobal(point);
		else
			return (visualElement as DisplayObject).localToGlobal(point);
	}
}
}