package cream.components
{
import cream.components.sheets.Sheet;
import cream.eventing.eventdispatchers.IEventDispatcher;
import cream.eventing.events.ClipboardEvent;
import cream.eventing.events.CompositeEvent;
import cream.eventing.events.DimensionChangeEvent;
import cream.eventing.events.Event;
import cream.eventing.events.ExternalDimensionChangeEvent;
import cream.eventing.events.FocusEvent;

import flash.desktop.InteractiveIcon;
import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.errors.IllegalOperationError;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.sampler.StackFrame;

import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;

import spark.components.Application;
import spark.components.Button;
import spark.components.Group;
import spark.core.IGraphicElement;

public class Component extends Composite implements IComponent
{		
	private var _visualElement:IVisualElement;
	private var _visualElementContainer:IVisualElementContainer;
	private var _hasFocus:Boolean = false;
	
	protected function get visualElement():IVisualElement {  return _visualElement;  }
	protected function set visualElement(val:IVisualElement):void {  _visualElement = val;  }
	protected function get visualElementContainer():IVisualElementContainer	{  return _visualElementContainer;	}
	protected function set visualElementContainer(val:IVisualElementContainer):void {  _visualElementContainer = val; }
	protected function get parentComponent():IComponent { return parent as IComponent; }
	
	_protected_ function get visualElement():IVisualElement  { return visualElement; }
	_protected_ function get visualElementContainer():IVisualElementContainer  { return visualElementContainer; }
	
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
			if(parent)  {
				(parent as Component).dispatchFocusInEvent();
				for each(var sibling:Component in parent._protected_::children)  {
					if(sibling != self)
						sibling.dispatchFocusOutEvent();
				}
			}
		});
		
		addFocusOutEventListener( function(e:FocusEvent):void {
			for each(var child:Composite in children)
			{
				(child as Component).dispatchFocusOutEvent();
			}
		});
		
		addAddedEventListener(onAdded);
		
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

	private function onAdded(e:CompositeEvent):void 
	{
		// event only valid on first addition
		removeAddedEventListener( onAdded );
		
		visualElement.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
		{
			if(e.target.parent != visualElement)
				return;
			
			bringSystemFocus();
		});
		
		
		// To make use of system clipboard event
		visualElement.addEventListener(flash.events.Event.COPY, function(e:flash.events.Event):void 
		{
			dispatchCopyEvent(self);
		});
		
		visualElement.addEventListener(flash.events.Event.CUT, function(e:flash.events.Event):void 
		{ 
			dispatchCutEvent(self);
		});
		
		visualElement.addEventListener(flash.events.Event.PASTE, function(e:flash.events.Event):void 
		{ 
			dispatchPasteEvent(self);
		});
		
	}
	
	private function onSystemClipboardCopy(e:ClipboardEvent):void
	{
		dispatchCopyEvent(e.dispatcher);
	}
	
	private function onSystemClipboardCut(e:ClipboardEvent):void
	{
		dispatchCutEvent(e.dispatcher);
	}
	
	private function onSystemClipboardPaste(e:ClipboardEvent):void
	{
		dispatchPasteEvent(e.dispatcher);
	}
	
	override protected function addChild(child:Composite):Composite
	{
		var vchild:Component = child as Component;
		if(vchild == null)  {
			new Error("child must be a component");
			return null;
		}
		
		attachSparkElement(vchild.visualElement);
		// For propagating System Clipboard event
		vchild.addCopyEventListener( onSystemClipboardCopy );
		vchild.addCutEventListener( onSystemClipboardCut );
		vchild.addPasteEventListener( onSystemClipboardPaste );
		
		super.addChild(child);
	
		return child;
	}
	
	protected function addChild2(child:Composite):Composite
	{
		var vchild:Component = child as Component;
		if(vchild == null)  {
			new Error("child must be a component");
			return null;
		}
		
		attachSparkElement(vchild.visualElement);
//		// For propagating System Clipboard event
//		vchild.addCopyEventListener( onCopy );
//		vchild.addCutEventListener( onCut );
//		vchild.addPasteEventListener( onPaste );
//		
		super.addChild(child);
//		
		return child;
	}
	
	override protected function removeChild(child:Composite):Composite
	{
		var vchild:Component = child as Component;
		if(vchild == null)  {
			new Error("child must be a component");
			return null;
		}
		
		// For propagating System Clipboard event
		vchild.removePasteEventListener( onSystemClipboardPaste );
		vchild.removeCutEventListener( onSystemClipboardCut );
		vchild.removeCopyEventListener( onSystemClipboardCopy );
		
		detachSparkElement(vchild.visualElement);
		
		return super.removeChild(child);
	}
	
	protected function attachSparkElement(sparkElement:IVisualElement):void
	{
		visualElementContainer.addElement( sparkElement );
	}
	
	protected function detachSparkElement(sparkElement:IVisualElement):void
	{
		visualElementContainer.removeElement( sparkElement );
	}
	
	override protected function removeAllChildren():void
	{
		for(var i:int = numChildren-1; i >=0; i --)
		{
			var child:Component = children.removeItemAt(i) as Component;
			child.parent = null;
			visualElementContainer.removeElement(child.visualElement);
			
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
	
	public function addCopyEventListener(listener:Function):void
	{
		addEventListener(ClipboardEvent.COPY, listener);
	}
	
	public function removeCopyEventListener(listener:Function):void
	{
		removeEventListener(ClipboardEvent.COPY, listener);
	}
	
	public function addCutEventListener(listener:Function):void
	{
		addEventListener(ClipboardEvent.CUT, listener);
	}
	
	public function removeCutEventListener(listener:Function):void
	{
		removeEventListener(ClipboardEvent.CUT, listener);
	}
	
	public function addPasteEventListener(listener:Function):void
	{
		addEventListener(ClipboardEvent.PASTE, listener);
	}
	
	public function removePasteEventListener(listener:Function):void
	{
		removeEventListener(ClipboardEvent.PASTE, listener);
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
	
	public static function get savedFocus():InteractiveObject { return _savedFocus; }
	
	private static var _savedFocus:InteractiveObject;
	

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
	
	
	_protected_ function dispatchFocusInEvent():void
	{
		dispatchFocusInEvent();
	}
	
	_protected_ function dispatchFocusOutEvent():void
	{
		dispatchFocusOutEvent();
	}
		
	
	protected function dispatchDimensionChangeEvent(oldRect:Rectangle, newRect:Rectangle):void
	{
		dispatchEvent(new DimensionChangeEvent(this, oldRect, newRect));
	}
	
	protected function dispatchExternalDimensionChangeEvent():void
	{
		dispatchEvent(new ExternalDimensionChangeEvent(this));
	}
	
	
	protected function dispatchCopyEvent(dispatcher:IEventDispatcher):void
	{
		dispatchEvent(new ClipboardEvent(dispatcher, ClipboardEvent.COPY));
	}
	
	protected function dispatchCutEvent(dispatcher:IEventDispatcher):void
	{
		dispatchEvent(new ClipboardEvent(dispatcher, ClipboardEvent.CUT));
	}
	
	protected function dispatchPasteEvent(dispatcher:IEventDispatcher):void
	{
		dispatchEvent(new ClipboardEvent(dispatcher, ClipboardEvent.PASTE));
	}
	
	
	
	protected function get stage():Stage
	{
		return (visualElement as DisplayObject).stage;
	}

	
	protected function get application():Application
	{
		return FlexGlobals.topLevelApplication as Application;
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
	
	protected function bringSystemFocus():void { stage.focus = visualElement as InteractiveObject; _savedFocus = stage.focus; }
	
	protected function dispatchComponentFocusInEvent(component:Component):void
	{
		component.dispatchFocusInEvent();
	}
	
	protected function dispatchComponentFocusOutEvent(component:Component):void
	{
		component.dispatchFocusOutEvent();
	}

	
	
}
}