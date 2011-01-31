package components.controls
{
import components.events.ChildrenEvent;

public class VerticalScrollbar extends ScrollbarBase
{
	public function VerticalScrollbar(target:IScrollable)
	{
		super(target);
		this.width = defaultThickness;
		this.target.addEventListener(ChildrenEvent.DIMENSION_CHANGE, updateScrollbar);
	}
	
	private function updateScrollbar(e:ChildrenEvent):void  {
		var ratioLength:Number = target.verticalScrollRatioLength;
		this.x = target.width-10;
		this.y = (target.height-10)*target.verticalScrollRatioPos;
		this.height = (target.height-10)*ratioLength;
		
		if(ratioLength >= 1.0)
			this.hide();
		else
			this.show();
	}
	
}
}