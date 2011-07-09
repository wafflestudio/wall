package components.scrollers
{
import components.Component;
import eventing.events.ScrollEvent;
import components.scrollbars.HScrollbarUIComponent;
import components.scrollbars.VScrollbarUIComponent;
import spark.components.Group;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.events.ResizeEvent;
import flash.geom.Rectangle;
import mx.core.UIComponent;
import flash.utils.setTimeout;
import spark.components.BorderContainer;
import components.scrollbars.ScrollbarUIComponent;

public class Scroller extends Component implements IScroller
{
	public static const padding:Number = 5;
	private var group:Group = new Group();
	private var hScrollbar:HScrollbarUIComponent;
	private var vScrollbar:VScrollbarUIComponent;
	private var hPos:Number;
	private var vPos:Number;
	private var hLen:Number;
	private var vLen:Number;
	
	override protected function get visualElement():IVisualElement { return group; }
	override protected function get visualElementContainer():IVisualElementContainer { return group; }
	
	public function Scroller()
	{
		super();
		group.percentHeight = 100;
		group.percentWidth = 100;
		group.clipAndEnableScrolling = true;
		
		hScrollbar = new HScrollbarUIComponent();
		vScrollbar = new VScrollbarUIComponent();
		group.addEventListener(ResizeEvent.RESIZE, function (e:ResizeEvent):void {
			refresh();
		});
		
		visualElementContainer.addElement(hScrollbar);
		visualElementContainer.addElement(vScrollbar);
		
	}
	
	public function update(rect:Rectangle, crect:Rectangle):void
	{
		var min:Number = crect.y < 0 ? crect.y : 0;
		var max:Number = crect.y+crect.height > 0+rect.height ? 
			crect.y+crect.height : 0+rect.height;
		vPos = (rect.y-min)/(max-min);
		vLen = rect.height/(max-min);
		
		min = crect.x < 0 ? crect.x : 0;
		max = crect.x+crect.width > 0+rect.width ? 
			crect.x+crect.width : 0+rect.width;
		
		hPos = (rect.x-min)/(max-min);
		hLen = rect.width/(max-min);

		refresh();
	}
	
	public function refresh():void
	{
		var width:Number = group.width - 20;
		var height:Number = group.height - 20;
		
		hScrollbar.x = hPos * width + padding;
		hScrollbar.width = hLen * width;
		hScrollbar.bottom = padding;
		
		vScrollbar.y = vPos * height + padding;
		vScrollbar.height = vLen * height;
		vScrollbar.right = padding;
		
	}
	
	public function set horizontalScrollPosRatio(val:Number):void
	{
		hPos = val;
		refresh();	
	}
	
	public function set horizontalScrollLengthRatio(val:Number):void
	{
		hLen = val;
		refresh();	
	}
	
	public function set verticalScrollPosRatio(val:Number):void
	{
		vPos = val;
		refresh();	
	}
	
	public function set verticalScrollLengthRatio(val:Number):void
	{
		vLen = val;
		refresh();	
	}
	
	
	public function addScrollEventListener(listener:Function):void
	{
		addEventListener(ScrollEvent.SCROLL, listener);
	}
	
	public function removeScrollEventListener(listener:Function):void
	{
		removeEventListener(ScrollEvent.SCROLL, listener);	
	}
	
	protected function dispatchScrollEvent(hPos:Number, hLen:Number, vPos:Number, vLen:Number):void
	{
		dispatchEvent(new ScrollEvent(this, hPos, hLen, vPos, vLen));
	}
}
}