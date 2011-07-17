package components.containers
{
import components.Component;
import flash.geom.Rectangle;
import flash.display.DisplayObject;
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
	
	public function get panX():Number
	{
		return (visualElementContainer as IVisualElement).x;
	}
	
	public function get panY():Number
	{
		return (visualElementContainer as IVisualElement).y;
	}
	
	public function get zoomX():Number
	{
		return (visualElementContainer as DisplayObject).scaleX;
	}
	
	public function get zoomY():Number
	{
		return (visualElementContainer as DisplayObject).scaleY;
	}
	
	
	public function set _panX(x:Number):void
	{
		(visualElementContainer as IVisualElement).x = x;
	}
	
	public function set _panY(y:Number):void
	{
		(visualElementContainer as IVisualElement).y = y;
	}
	
	public function set _zoomX(x:Number):void
	{
		(visualElementContainer as DisplayObject).scaleX = x;
	}
	
	public function set _zoomY(y:Number):void
	{
		(visualElementContainer as DisplayObject).scaleY = y;
	}
	
	protected function bringToFront(component:Component):void
	{
		setChildIndex(component, numChildren-1); 	
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