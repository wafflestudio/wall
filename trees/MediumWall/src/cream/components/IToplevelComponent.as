package cream.components
{
	import mx.core.IVisualElementContainer;


public interface IToplevelComponent
{
	function addToApplication(app:IVisualElementContainer = null):void;
	function removeFromApplication(app:IVisualElementContainer = null):void;
}
}