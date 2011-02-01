package components
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Rectangle;
import mx.core.IVisualElement;
import spark.components.BorderContainer;
import spark.components.Group;
import components.interfaces.IScrollable;
import flash.events.MouseEvent;
import mx.core.UIComponent;
import mx.core.IVisualElementContainer;
import flash.events.FocusEvent;

[Event(name="updated", type="flash.events.Event")]
public class SpatialObject extends BorderContainer implements IScrollable
{
	public function SpatialObject()
	{
		super();
		this.attachChildrenContainer();
		
		// Default Focus event for non-text areas
		this.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void 
			{ 
				setFocus();
			}, false, -1
		);
	}
	
	
	public function get horizontalScrollPosRatio():Number
	{
		var crect:Rectangle = adjustedChildrenExtent;
		var rect:Rectangle = extent;
		var min:Number = crect.x < 0 ? crect.x : 0;
		var max:Number = crect.x+crect.width > 0+rect.width ? 
						  crect.x+crect.width : 0+rect.width;
		var ratioPos:Number = (rect.x-min)/(max-min);
		
		return ratioPos;
	}
	
	public function get horizontalScrollLengthRatio():Number
	{
		var crect:Rectangle = adjustedChildrenExtent;
		var rect:Rectangle = extent;
		var min:Number = crect.x < 0 ? crect.x : 0;
		var max:Number = crect.x+crect.width > 0+rect.width ? 
						 crect.x+crect.width : 0+rect.width;
		var percentLength:Number = rect.width/(max-min);
		
		return percentLength;
	}
	
	public function get verticalScrollPosRatio():Number
	{
		var crect:Rectangle = adjustedChildrenExtent;
		var rect:Rectangle = extent;
		var min:Number = crect.y < 0 ? crect.y : 0;
		var max:Number = crect.y+crect.height > 0+rect.height ? 
						 crect.y+crect.height : 0+rect.height;
		var percentPos:Number = (rect.y-min)/(max-min);
		
		return percentPos;
	}
	
	public function get verticalScrollLengthRatio():Number
	{
		var crect:Rectangle = adjustedChildrenExtent;
		var rect:Rectangle = extent;
		var min:Number = crect.y < 0 ? crect.y : 0;
		var max:Number = crect.y+crect.height > 0+rect.height ? 
			crect.y+crect.height : 0+rect.height;
		var percentLength:Number = rect.height/(max-min);
		
		return percentLength;
	}
	
	protected var childrenContainer:Group = new Group();
	
	protected function get childrenExtent():Rectangle  {
		var found:Boolean = false;
		var minx:Number = 0;
		var maxx:Number = 0;
		var miny:Number = 0;
		var maxy:Number = 0;
		
		for(var i:int  = 0; i < childrenContainer.numElements; i++)  {
			var element:DisplayObject = childrenContainer.getElementAt(i) as DisplayObject;
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
	
	protected function get adjustedChildrenExtent():Rectangle  {
		var rect:Rectangle = childrenExtent;
		
		return new Rectangle(childrenContainer.x + rect.x * this.childrenContainer.scaleX, 
			childrenContainer.y + rect.y * this.childrenContainer.scaleY, 
			rect.width * this.childrenContainer.scaleX, 
			rect.height * this.childrenContainer.scaleY);
	}
	
	protected function get extent():Rectangle  {		
		return new Rectangle(this.x, this.y, this.width, this.height);
	}
	
	private function attachChildrenContainer():void  {
		this.addElement(childrenContainer);
	}
	
	protected function bringToFront(e:MouseEvent):void  {
		if(parent)  {
			(parent as IVisualElementContainer).setElementIndex(this, parent.numChildren-1);
		}
		
	}
	
	
}
}