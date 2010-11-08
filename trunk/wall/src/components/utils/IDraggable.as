package components.utils
{
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	public interface IDraggable
	{
		function dragInit():void;
		function dragStart(e:MouseEvent):void;
		function dragEnd(e:MouseEvent):void;
		function drag(e:MouseEvent):void;
	}
}