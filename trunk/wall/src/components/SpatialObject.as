package components
{
import components.events.MoveEvent;
import components.events.SpatialEvent;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Rectangle;

import mx.core.IVisualElement;

import spark.components.BorderContainer;
import spark.components.Group;

[Event(name="updated", type="flash.events.Event")]
public class SpatialObject extends BorderContainer
{
	public function SpatialObject()
	{
		super();
		// TODO: revise
		this.addEventListener("updated", onUpdate);
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