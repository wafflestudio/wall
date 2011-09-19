package cream.components.containers
{
import cream.components.Component;

import flash.display.DisplayObject;
import flash.geom.Rectangle;

import mx.core.IVisualElement;

public class Container extends Component implements IContainer
{
	public function Container()
	{
		
	}
	
	// extent of children unscaled
	protected function get unscaledChildrenExtent():Rectangle  {
		var found:Boolean = false;
		var minx:Number = 0;
		var maxx:Number = 0;
		var miny:Number = 0;
		var maxy:Number = 0;
		
		for(var i:int  = 0; i < visualElementContainer.numElements; i++)  {
			var element:IVisualElement = visualElementContainer.getElementAt(i) as IVisualElement;
			if(element)  {
				if(!found) {
					found = true;
					minx = element.x;
					miny = element.y;
					maxx = element.x + element.width;
					maxy = element.y + element.height;
				} 
				else {					
					if(maxx < (element.x + element.width))  
						maxx = (element.x + element.width);
					if(minx > element.x)
						minx = element.x;
					if(maxy < (element.y + element.height))  
						maxy = (element.y + element.height);
					if(miny > element.y)
						miny = element.y;						
				}
			}
		}
		
		return new Rectangle(minx, miny, maxx-minx, maxy-miny);
	}
	
	// extent of children, scaled by current component scale
	protected function get childrenExtent():Rectangle  {
		var rect:Rectangle = unscaledChildrenExtent;
	
		return new Rectangle(panX + rect.x * zoomX, 
			panY + rect.y * zoomY, 
			rect.width * zoomX, 
			rect.height * zoomY);
	}
	
	
	protected function get extent():Rectangle  {	
		return new Rectangle(visualElement.x, visualElement.y, visualElement.width, visualElement.height);
	}
	
	
	public function get panX():Number { return _panX; }
	public function get panY():Number { return _panY; }
	public function get zoomX():Number { return _zoomX; }
	public function get zoomY():Number { return _zoomY; }
	
	protected function get _panX():Number { return (visualElementContainer as IVisualElement).x; }
	protected function get _panY():Number { return (visualElementContainer as IVisualElement).y; }
	protected function get _zoomX():Number { return (visualElementContainer as DisplayObject).scaleX; }
	protected function get _zoomY():Number { return (visualElementContainer as DisplayObject).scaleY; }
	
	protected function set _panX(x:Number):void { (visualElementContainer as IVisualElement).x = x; }
	protected function set _panY(y:Number):void { (visualElementContainer as IVisualElement).y = y; }
	protected function set _zoomX(x:Number):void { (visualElementContainer as DisplayObject).scaleX = x; }
	protected function set _zoomY(y:Number):void { (visualElementContainer as DisplayObject).scaleY = y; }
	
	protected function bringToFront(component:Component):void
	{
		visualElementContainer.setElementIndex(component._protected_::visualElement, numChildren-1);	
	}
	
	
	
	override protected function reset():void
	{
		super.reset();
		_panX = 0;
		_panY = 0;
		_zoomX = 0;
		_zoomY = 0;
	}
	
}
}