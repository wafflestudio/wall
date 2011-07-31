package components
{
	import mx.core.IVisualElementContainer;


public interface IToplevelComponent
{
	function addToApplication(app:IVisualElementContainer):void;
	function removeFromApplication(app:IVisualElementContainer = null):void;
}
}