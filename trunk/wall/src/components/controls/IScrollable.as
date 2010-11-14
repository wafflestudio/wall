package components.controls
{
import flash.events.IEventDispatcher;

import mx.core.IVisualElement;

public interface IScrollable extends IEventDispatcher
{
	function get width():Number;
	function get height():Number;
	function get horizontalScrollRatioPos():Number;
	function get horizontalScrollRatioLength():Number;
	function get verticalScrollRatioPos():Number;
	function get verticalScrollRatioLength():Number;
	function addElement(element:IVisualElement):IVisualElement;
}

}