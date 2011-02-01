package behaviors.capabilities
{
import components.SpatialObject;
import flash.events.MouseEvent;
import spark.components.Group;
import behaviors.events.ChildrenEvent;
import mx.core.UIComponent;

public class Scalability
{
	private var target:SpatialObject;
	private var childrenContainer:UIComponent;
	
	public function Scalability(target:SpatialObject, childrenContainer:UIComponent)
	{
		this.target = target;
		this.childrenContainer = childrenContainer;
		
		activate();
	}
	
	
	private function activate():void  {
		
		target.addEventListener(MouseEvent.MOUSE_WHEEL,function(e:MouseEvent):void {
			var multiplier:Number = Math.pow(1.03, e.delta);
			multiplyContentScale(multiplier);
			target.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE));
		});
	}
	
	
	private function multiplyContentScale(multiplier:Number):void  {
		// keep minimum scale to 0.1
		const MIN_SCALE:Number = 0.1;
		if(multiplier < 1.0 && (childrenContainer.scaleX <= MIN_SCALE || childrenContainer.scaleY <= MIN_SCALE))
		{
			multiplier = MIN_SCALE / (childrenContainer.scaleX < childrenContainer.scaleY ? 
				childrenContainer.scaleY : childrenContainer.scaleX);
			
			childrenContainer.scaleX = MIN_SCALE;
			childrenContainer.scaleY = MIN_SCALE;
		}
		else  {
			childrenContainer.scaleX *= multiplier;
			childrenContainer.scaleY *= multiplier;
		}
		childrenContainer.x = (childrenContainer.x - target.width/2) * multiplier + target.width/2;
		childrenContainer.y = (childrenContainer.y - target.height/2) * multiplier + target.height/2;
	}
}
}