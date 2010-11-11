package components
{
import components.controls.IScrollable;
import components.events.MoveEvent;
import components.events.SpatialEvent;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Rectangle;

import mx.core.IVisualElement;

import spark.components.BorderContainer;
import spark.components.Group;

[Event(name="updated", type="flash.events.Event")]
public class SpatialObject extends BorderContainer implements IScrollable
{
	public function SpatialObject()
	{
		super();
		// TODO: revise
		this.addEventListener("updated", onUpdate);
	}
	
	public function get horizontalScrollRatioPos():Number
	{
		var crect:Rectangle = scaledChildrenExtent;
		var rect:Rectangle = extent;
		var min:Number = crect.x < rect.x ? crect.x : rect.x;
		var max:Number = crect.x+crect.width < rect.x+rect.width ? 
						  crect.x+crect.width : rect.x+rect.width;
		var percentPos:Number = (rect.x-min)/(max-min);
		
		return percentPos;
	}
	
	public function get horizontalScrollRatioLength():Number
	{
		var crect:Rectangle = scaledChildrenExtent;
		var rect:Rectangle = extent;
		var min:Number = crect.x < rect.x ? crect.x : rect.x;
		var max:Number = crect.x+crect.width < rect.x+rect.width ? 
						 crect.x+crect.width : rect.x+rect.width;
		var percentLength:Number = rect.width/(max-min);
		
		return percentLength;
	}
	
	public function get verticalScrollRatioPos():Number
	{
		var crect:Rectangle = scaledChildrenExtent;
		var rect:Rectangle = extent;
		var min:Number = crect.y < rect.y ? crect.y : rect.y;
		var max:Number = crect.y+crect.height < rect.x+rect.height ? 
						 crect.y+crect.height : rect.x+rect.height;
		var percentPos:Number = (rect.x-min)/(max-min);
		
		return percentPos;
	}
	
	public function get verticalScrollRatioLength():Number
	{
		var crect:Rectangle = scaledChildrenExtent;
		var rect:Rectangle = extent;
		var min:Number = crect.y < rect.x ? crect.y : rect.y;
		var max:Number = crect.y+crect.width < rect.y+rect.width ? 
			crect.x+crect.width : rect.y+rect.width;
		var percentLength:Number = rect.width/(max-min);
		
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
	
	protected function get scaledChildrenExtent():Rectangle  {
		var rect:Rectangle = childrenExtent;
		
		return new Rectangle(rect.x * this.childrenContainer.scaleX, 
			rect.y * this.childrenContainer.scaleY, 
			rect.width * this.childrenContainer.scaleX, 
			rect.height * this.childrenContainer.scaleY);
	}
	
	protected function get extent():Rectangle  {		
		return new Rectangle(this.x, this.y, this.width, this.height);
	}
	
	private function onUpdate(e:Event):void  {
			
	}
	
	
}
}