package components.containers
{
import components.IComponent;

public interface IContainer extends IComponent
{	
	function get panX():Number;
//	function set panX(val:Number):void;
	function get panY():Number;
//	function set panY(val:Number):void;
	
	function get zoomX():Number;
//	function set zoomX(val:Number):void;
	function get zoomY():Number;
//	function set zoomY(val:Number):void;
	
}
}