package cream.components.containers
{
import cream.components.Component;
import cream.components.Composite;
import cream.components.IComponent;
import cream.components.scrollbars.HScrollbarUIComponent;
import cream.components.scrollbars.VScrollbarUIComponent;
import cream.components.scrollers.Scroller;

import eventing.events.ChildrenDimensionChangeEvent;
import eventing.events.DimensionChangeEvent;
import eventing.events.ScrollEvent;

import flash.geom.Rectangle;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.events.ResizeEvent;

import spark.components.Group;

public class ScrollableContainer extends Container implements IScrollableContainer
{
	
	private var _viewport:Group = new Group();
	private var _scroller:Scroller;
	
	protected function get viewport():Group {	return _viewport;	}
	
	protected function set scroller(s:Scroller):void
	{
		if(_scroller)
			viewport.removeElement(s._protected_::visualElement);
		
		viewport.addElement(s._protected_::visualElement);
		
		
		_scroller = s;
		
		s.addScrollEventListener( function(e:ScrollEvent):void {
			
		});
	}
	
	
	public function ScrollableContainer()
	{
		super();
		
		(visualElement as IVisualElementContainer).addElement(viewport);
		viewport.addElement(visualElementContainer as IVisualElement);
			
		_viewport.percentHeight = 100;
		_viewport.percentWidth = 100;
		
		_viewport.clipAndEnableScrolling = true;
		_viewport.setStyle("horizontalScrollPolicy", "off");
		
		scroller = new Scroller();
		
		this.addChildrenDimensionChangeEventListener( function(e:ChildrenDimensionChangeEvent):void {
			if(_scroller)
				_scroller.update(extent, childrenExtent);
			
		});
		
		
	}
	
	
	private function onChildDimensionChange(e:DimensionChangeEvent):void 
	{
		dispatchChildrenDimensionChangeEvent();
	};
	
	override protected function addChild(child:Composite):Composite
	{
		
		super.addChild(child);
		(child as Component).addDimensionChangeEventListener(onChildDimensionChange);
		dispatchChildrenDimensionChangeEvent();
		
		return child;
	}
	
	override protected function removeChild(child:Composite):Composite
	{
		(child as Component).removeDimensionChangeEventListener( onChildDimensionChange );
		super.removeChild(child);
		dispatchChildrenDimensionChangeEvent();
		
		return child;
	}
	
	
	public function addChildrenDimensionChangeEventListener(listener:Function):void
	{
		addEventListener(ChildrenDimensionChangeEvent.CHILDREN_DIMENSION_CHANGE, listener);
	}
	
	public function removeChildrenDimensionChangeEventListener(listener:Function):void
	{
		removeEventListener(ChildrenDimensionChangeEvent.CHILDREN_DIMENSION_CHANGE, listener);	
	}
	
	
	protected function dispatchChildrenDimensionChangeEvent():void
	{
		dispatchEvent( new ChildrenDimensionChangeEvent(this));
	}
}
}