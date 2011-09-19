package cream.components.scrollers
{
import cream.components.IComponent;
import eventing.eventdispatchers.IScrollEventDispatcher;

public interface IScroller extends IComponent, IScrollEventDispatcher
{
	function set horizontalScrollPosRatio(val:Number):void;
	function set horizontalScrollLengthRatio(val:Number):void;
	
	function set verticalScrollPosRatio(val:Number):void;
	function set verticalScrollLengthRatio(val:Number):void;
}
}