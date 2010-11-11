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
		this.y = (target.height-10)*target.verticalScrollRatioPos;
		this.height = (target.height-10)*target.verticalScrollRatioLength;
	}
	
}
}