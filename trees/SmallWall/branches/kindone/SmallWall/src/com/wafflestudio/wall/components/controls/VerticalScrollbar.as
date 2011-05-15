package com.wafflestudio.wall.components.controls
{

import com.wafflestudio.wall.interfaces.IScrollable;
import com.wafflestudio.wall.events.ChildrenEvent;

public class VerticalScrollbar extends ScrollbarBase
{
	public function VerticalScrollbar(target:IScrollable)
	{
		super(target);
		this.width = defaultThickness;
		this.target.addEventListener(ChildrenEvent.DIMENSION_CHANGE, updateScrollbar);
	}
	
	private function updateScrollbar(e:ChildrenEvent):void  {
		var ratioLength:Number = target.verticalScrollLengthRatio;
		this.x = target.width-10;
		this.y = (target.height-10)*target.verticalScrollPosRatio;
		this.height = (target.height-10)*ratioLength;
		
		if(ratioLength >= 1.0)
			this.hide();
		else
			this.show();
	}
	
}
}