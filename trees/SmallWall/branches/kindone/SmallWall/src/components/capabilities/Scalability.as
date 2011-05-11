package components.capabilities
{
import components.Component;
import flash.events.MouseEvent;
import spark.components.Group;
import components.events.ChildrenEvent;
import mx.core.UIComponent;

public class Scalability
{
	private var target:Component;
	
	
	public function Scalability(target:Component)
	{
		this.target = target;

		
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
		if(multiplier < 1.0 && (target.zoomX <= MIN_SCALE || target.zoomY <= MIN_SCALE))
		{
			multiplier = MIN_SCALE / (target.zoomX < target.zoomY ? 
				target.zoomY : target.zoomX);
			
			target.zoomX = MIN_SCALE;
			target.zoomY = MIN_SCALE;
		}
		else  {
			target.zoomX *= multiplier;
			target.zoomY *= multiplier;
		}
		target.panX = (target.panX - target.width/2) * multiplier + target.width/2;
		target.panY = (target.panY - target.height/2) * multiplier + target.height/2;
	}
}
}