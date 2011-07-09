package components.scrollbars
{


public class VScrollbarUIComponent extends ScrollbarUIComponent
{
	public function VScrollbarUIComponent()
	{
		super();
		super.width = defaultThickness;
	}
	
	override public function set width(value:Number):void
	{
		// do nothing
	}

	protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void  {
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		this.graphics.clear();
		this.graphics.beginFill(0x0, defaultMaxOpacity);
		this.graphics.drawRoundRect(0,0, unscaledWidth-defaultPadding, unscaledHeight, 5 , 5);	
		this.graphics.endFill();
	}
	
	
//	private function updateScrollbar(e:ChildrenEvent):void  {
//		var ratioLength:Number = target.verticalScrollLengthRatio;
//		this.x = target.width-10;
//		this.y = (target.height-10)*target.verticalScrollPosRatio;
//		this.height = (target.height-10)*ratioLength;
//		
//		if(ratioLength >= 1.0)
//			this.hide();
//		else
//			this.show();
//	}
	
}
}