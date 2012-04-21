package cream.components
{
public interface IPositionedComponent extends IComponent
{
	function get x():Number;
	function set x(val:Number):void;
	function get y():Number;
	function set y(val:Number):void;
}
}