package com.wafflestudio.wall.components.controls
{

import flash.geom.Rectangle;
import com.wafflestudio.wall.interfaces.IScrollable;
import com.wafflestudio.wall.events.ChildrenEvent;

public class HorizontalScrollbar extends ScrollbarBase
{
	public function HorizontalScrollbar(target:IScrollable)  {
		super(target);
		this.height = defaultThickness;
		this.target.addEventListener(ChildrenEvent.DIMENSION_CHANGE, updateScrollbar);
	}
	
	private function updateScrollbar(e:ChildrenEvent):void  {
		var ratioLength:Number = target.horizontalScrollLengthRatio;
		
		this.y = target.height-10;
		this.x = (target.width-10)*target.horizontalScrollPosRatio;
		this.width = (target.width-10)*ratioLength;
		
		if(ratioLength >= 1.0)
			this.hide();
		else
			this.show();
	}
	
	
}
}