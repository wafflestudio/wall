package cream.components.containers
{
import cream.components.Component;
import cream.components.Composite;
import cream.components.IComponent;
import cream.components.scrollbars.HScrollbarUIComponent;
import cream.components.scrollbars.VScrollbarUIComponent;
import cream.components.scrollers.Scroller;

import cream.eventing.events.ChildrenDimensionChangeEvent;
import cream.eventing.events.DimensionChangeEvent;
import cream.eventing.events.ScrollEvent;

import flash.display.DisplayObject;

import flash.geom.Rectangle;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.events.ResizeEvent;

import spark.components.Group;
import spark.components.supportClasses.GroupBase;
import spark.core.IGraphicElementContainer;
import spark.core.ISharedDisplayObject;

public class ScrollableContainer extends Container implements IScrollableContainer
{
	private var defaultScroller:Scroller;

    protected function get viewport():Group {	return visualElementContainer as Group;	}
    protected function get scroller():Scroller { return defaultScroller; }

	public function ScrollableContainer()
	{
		super();
        initScroll();

		addChildrenDimensionChangeEventListener( function(e:ChildrenDimensionChangeEvent):void {
			if(scroller)
                scroller.update(extent, childrenExtent);
		});
		
		addChildAddedEventListener(function():void
		{
			dispatchChildrenDimensionChangeEvent();
		});
		
		addChildRemovedEventListener(function():void
		{
			dispatchChildrenDimensionChangeEvent();
		});
	}

    protected function initScroll():void
    {
        defaultScroller = new Scroller();
        viewport.addElement(defaultScroller._protected_::visualElement);

        viewport.clipAndEnableScrolling = true;
        viewport.setStyle("horizontalScrollPolicy", "off");
    }
	
	
	private function onChildDimensionChange(e:DimensionChangeEvent):void 
	{
		dispatchChildrenDimensionChangeEvent();
	};
	
	override protected function addChild(child:Composite):Composite
	{
        (child as Component).addDimensionChangeEventListener(onChildDimensionChange);
		super.addChild(child);

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