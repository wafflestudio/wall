package components.containers
{
import components.Component;
import flash.geom.Rectangle;
import components.scrollbars.HScrollbarUIComponent;
import components.scrollbars.VScrollbarUIComponent;
import eventing.events.ChildrenDimensionChangeEvent;
import mx.core.IVisualElementContainer;
import components.scrollers.Scroller;
import eventing.events.ScrollEvent;
import eventing.events.DimensionChangeEvent;
import mx.events.ResizeEvent;
import components.IComponent;
import spark.components.Group;
import mx.core.IVisualElement;

public class ScrollableContainer extends Container implements IScrollableContainer
{
	
	private var _viewport:Group = new Group();
	private var _scroller:Scroller;
	
	protected function get viewport():Group {	return _viewport;	}
	
	protected function set scroller(s:Scroller):void
	{
		if(_scroller)
			removeChildFrom(viewport, s);
		
		addChildTo(viewport, s);
		
		
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
	
	override protected function addChildTo(visualElementContainer:IVisualElementContainer, component:IComponent):void
	{
		super.addChildTo(visualElementContainer, component);
		component.addDimensionChangeEventListener(onChildDimensionChange);
		dispatchChildrenDimensionChangeEvent();
	}
	
	override protected function removeChildFrom(visualElementContainer:IVisualElementContainer, component:IComponent):void
	{
		component.removeDimensionChangeEventListener( onChildDimensionChange );
		super.removeChildFrom(visualElementContainer, component);
		dispatchChildrenDimensionChangeEvent();
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