package components
{
import eventing.eventdispatchers.IMoveEventDispatcher;

public interface IMovableComponent extends IComponent, IMoveEventDispatcher
{
	function get x():Number;
	function set x(val:Number):void;
	function get y():Number;
	function set y(val:Number):void;
}
}