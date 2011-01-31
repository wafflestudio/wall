package components.controls
{
import components.events.ChildrenEvent;

import flash.geom.Rectangle;

public class HorizontalScrollbar extends ScrollbarBase
{
	public function HorizontalScrollbar(target:IScrollable)  {
		super(target);
		this.height = defaultThickness;
		this.target.addEventListener(ChildrenEvent.DIMENSION_CHANGE, updateScrollbar);
	}
	
	private function updateScrollbar(e:ChildrenEvent):void  {
		var ratioLength:Number = target.horizontalScrollRatioLength;
		
		this.y = target.height-10;
		this.x = (target.width-10)*target.horizontalScrollRatioPos;
		this.width = (target.width-10)*ratioLength;
		
		if(ratioLength >= 1.0)
			this.hide();
		else
			this.show();
	}
	
	
}
}