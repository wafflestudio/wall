package components.controls
{
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	
	import mx.core.IVisualElement;

	public interface IResizable extends IEventDispatcher
	{
		function get width():Number;
		function get height():Number;
		function set width(value:Number):void;
		function set height(value:Number):void;
		function get x():Number;
		function get y():Number;
		function get parent():DisplayObjectContainer;
		function addElement(element:IVisualElement):IVisualElement;
	}
}