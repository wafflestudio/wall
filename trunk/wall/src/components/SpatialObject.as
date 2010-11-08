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
	
	protected var childrenHolder:Group = new Group();
	
	protected function get childrenExtent():Rectangle  {
		var found:Boolean = false;
		var minx:Number = 0;
		var maxx:Number = 0;
		var miny:Number = 0;
		var maxy:Number = 0;
		
		for(var i:int  = 0; i < childrenHolder.numElements; i++)  {
			var element:DisplayObject = childrenHolder.getElementAt(i) as DisplayObject;
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
	
	protected function get extent():Rectangle  {		
		return new Rectangle(this.x, this.y, this.width, this.height);
	}
	
	private function onUpdate(e:Event):void  {
			
	}
}
}