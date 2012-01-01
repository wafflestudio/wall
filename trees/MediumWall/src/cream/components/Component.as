package cream.components
{
import cream.eventing.eventdispatchers.IEventDispatcher;
import cream.eventing.events.ClipboardEvent;
import cream.eventing.events.CompositeEvent;
import cream.eventing.events.DimensionChangeEvent;
import cream.eventing.events.Event;
import cream.eventing.events.ExternalDimensionChangeEvent;
import cream.eventing.events.FocusEvent;

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import spark.components.Application;

public class Component extends Composite implements IComponent
{
	private var _hasFocus:Boolean = false;
	
	protected function get visualElement():IVisualElement {  return null;  }
	protected function get visualElementContainer():IVisualElementContainer	{  return null;	}

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

        initUnderlyingComponents();
    }

    protected function initUnderlyingComponents():void
    {
        throw new Error("Must override this method");
    }

	public function get x():Number  { return visualElement.x; }
	public function get y():Number  { return visualElement.y; }
	
	public function get width():Number { return visualElement.width; }
	public function get height():Number { return visualElement.height; }
	public function set width(val:Number):void { visualElement.width = val; }
	public function set height(val:Number):void { visualElement.height = val; }
	
	public function get percentWidth():Number { return visualElement.percentWidth; }
	public function get percentHeight():Number { return visualElement.percentHeight; }
	public function set percentWidth(val:Number):void { visualElement.percentWidth = val; }
	public function set percentHeight(val:Number):void { visualElement.percentHeight = val; }
	
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
		
		// Manage system focus (copy/paste depend on it)
		visualElement.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
		{
			if(e.target.owner != visualElement)
				return;
			
			bringSystemFocus();
		});
		
		
		// To make use of system clipboard event
		visualElement.addEventListener(flash.events.Event.COPY, function(e:flash.events.Event):void 
		{
			if(e.target != visualElement)
				return;
			
//			dispatchCopyEvent(self);
		});
		
		visualElement.addEventListener(flash.events.Event.CUT, function(e:flash.events.Event):void 
		{ 
			if(e.target != visualElement)
				return;
			
//			dispatchCutEvent(self);
		});
		
		visualElement.addEventListener(flash.events.Event.PASTE, function(e:flash.events.Event):void 
		{ 
			if(e.target != visualElement)
				return;
			
			var object:Object;
			var format:String;
				
			if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.TEXT_FORMAT))  {
				format = ClipboardEvent.TEXT_FORMAT;
				var string:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
				object = string;
			}
			else if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.BITMAP_FORMAT))  {
				format = ClipboardEvent.BITMAP_FORMAT;
				var bitmap:BitmapData = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT) as BitmapData;
				object = bitmap;
			}
//			if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.RICH_TEXT_FORMAT))  {
//				format = ClipboardEvent.RICH_TEXT_FORMAT;
//				var text:ByteArray = Clipboard.generalClipboard.getData(ClipboardFormats.RICH_TEXT_FORMAT) as ByteArray;
//				object = text;
//				trace("rtf", text);
//			}
//			if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.HTML_FORMAT))  {
//				format = ClipboardEvent.HTML_FORMAT;
//				var html:String = Clipboard.generalClipboard.getData(ClipboardFormats.HTML_FORMAT) as String;
//				object = html;
//				trace("html");
//			}
//			if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.URL_FORMAT))  {
//				format = ClipboardEvent.URL_FORMAT;
//				var url:String = Clipboard.generalClipboard.getData(ClipboardFormats.URL_FORMAT) as String;
//				object = url;
//				trace("url");
//			}
//			if(Clipboard.generalClipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))  {
//				format = ClipboardEvent.FILE_LIST_FORMAT;
//				var fileList:Array = Clipboard.generalClipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
//				object = fileList;
//				trace("file list");
//			}
		
			dispatchPasteEvent(self, format, object);
		});
		
	}
//	
//	private function onSystemClipboardCopy(e:ClipboardEvent):void
//	{
//		dispatchCopyEvent(e.dispatcher, e.format, e.object);
//	}
//	
//	private function onSystemClipboardCut(e:ClipboardEvent):void
//	{
//		dispatchCutEvent(e.dispatcher, e.format, e.object);
//	}
//	
//	private function onSystemClipboardPaste(e:ClipboardEvent):void
//	{
//		dispatchPasteEvent(e.dispatcher, e.format, e.object);
//	}
//	
	override protected function addChild(child:Composite):Composite
	{
		var vchild:Component = child as Component;
		if(vchild == null)  {
			new Error("child must be a component");
			return null;
		}
		
		attachSparkElement(vchild.visualElement);
//		// For propagating System Clipboard event
//		vchild.addCopyEventListener( onSystemClipboardCopy );
//		vchild.addCutEventListener( onSystemClipboardCut );
//		vchild.addPasteEventListener( onSystemClipboardPaste );
		
		super.addChild(child);
	
		return child;
	}
	
	
	override protected function removeChild(child:Composite):Composite
	{
		var vchild:Component = child as Component;
		if(vchild == null)  {
			new Error("child must be a component");
			return null;
		}
		
//		// For propagating System Clipboard event
//		vchild.removePasteEventListener( onSystemClipboardPaste );
//		vchild.removeCutEventListener( onSystemClipboardCut );
//		vchild.removeCopyEventListener( onSystemClipboardCopy );
		
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
	
	
	protected function dispatchCopyEvent(dispatcher:IEventDispatcher, format:String, object:Object):void
	{
		dispatchEvent(new ClipboardEvent(dispatcher, ClipboardEvent.COPY, format, object));
	}
	
	protected function dispatchCutEvent(dispatcher:IEventDispatcher, format:String, object:Object):void
	{
		dispatchEvent(new ClipboardEvent(dispatcher, ClipboardEvent.CUT, format, object));
	}
	
	protected function dispatchPasteEvent(dispatcher:IEventDispatcher, format:String, object:Object):void
	{
		dispatchEvent(new ClipboardEvent(dispatcher, ClipboardEvent.PASTE, format, object));
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