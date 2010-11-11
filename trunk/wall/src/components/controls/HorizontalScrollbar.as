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
		this.x = (target.width-10)*target.horizontalScrollRatioPos;
		this.width = (target.width-10)*target.horizontalScrollRatioLength;
	}
	
	
}
}