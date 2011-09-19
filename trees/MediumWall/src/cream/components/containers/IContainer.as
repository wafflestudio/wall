package cream.components.containers
{
import cream.components.IComponent;

public interface IContainer extends IComponent
{	
	function get panX():Number;
	function get panY():Number;
	function get zoomX():Number;
	function get zoomY():Number;
	
}
}