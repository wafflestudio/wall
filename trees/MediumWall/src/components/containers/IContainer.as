package components.containers
{
import components.IComponent;

public interface IContainer extends IComponent
{	
	function get panX():Number;
	function get panY():Number;
	function get zoomX():Number;
	function get zoomY():Number;
	
}
}