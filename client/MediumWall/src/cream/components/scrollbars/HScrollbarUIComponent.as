package cream.components.scrollbars
{

import flash.geom.Rectangle;
import flash.utils.setTimeout;

public class HScrollbarUIComponent extends ScrollbarUIComponent
{
	public function HScrollbarUIComponent()  {
		super();
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		super.height = defaultThickness;
	}
	
	
	override public function set height(value:Number):void
	{
		// do nothing
	}
	
	protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void  {
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		this.graphics.clear();
		this.graphics.beginFill(0x0, defaultMaxOpacity);
		this.graphics.drawRoundRect(0,0, unscaledWidth, unscaledHeight-defaultPadding, 5 , 5);	
	}
	
//	private function updateScrollbar(e:ChildrenEvent):void  {
//		var ratioLength:Number = target.horizontalScrollLengthRatio;
//		
//		this.y = target.height-10;
//		this.x = (target.width-10)*target.horizontalScrollPosRatio;
//		this.width = (target.width-10)*ratioLength;
//		
//		if(ratioLength >= 1.0)
//			this.hide();
//		else
//			this.show();
//	}
	
	
}
}