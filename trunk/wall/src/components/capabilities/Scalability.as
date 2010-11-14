package components.capabilities
{
import components.SpatialObject;
import flash.events.MouseEvent;
import spark.components.Group;
import components.events.ChildrenEvent;

public class Scalability
{
	private var target:SpatialObject;
	private var childrenContainer:Group;
	
	public function Scalability(target:SpatialObject, childrenContainer:Group)
	{
		this.target = target;
		this.childrenContainer = childrenContainer;
		
		addWheelScaleEventHandler();
	}
	
	
	private function addWheelScaleEventHandler():void  {
		
		target.addEventListener(MouseEvent.MOUSE_WHEEL,function(e:MouseEvent):void {
			var multiplier:Number = Math.pow(1.1, e.delta);
			multiplyContentScale(multiplier);
			target.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE));
		});
	}
	
	
	private function multiplyContentScale(multiplier:Number):void  {
		childrenContainer.scaleX *= multiplier;
		childrenContainer.scaleY *= multiplier;
		childrenContainer.x = (childrenContainer.x - target.width/2) * multiplier + target.width/2;
		childrenContainer.y = (childrenContainer.y - target.height/2) * multiplier + target.height/2;
	}
}
}