package components.buttons
{
import components.IComponent;
import eventing.eventdispatchers.IMouseEventDispatcher;
import components.IClickableComponent;

public interface IButton extends IClickableComponent
{
	function set label(text:String):void;
	function set enabled(value:Boolean):void;
}
}