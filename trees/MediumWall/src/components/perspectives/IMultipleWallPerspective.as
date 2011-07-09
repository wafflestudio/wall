package components.perspectives
{
import components.walls.IWall;
import components.sheets.ISheet;
import eventing.eventdispatchers.ISelectionChangeEventDispatcher;

public interface IMultipleWallPerspective extends IPerspective, ISelectionChangeEventDispatcher
{
	function get currentWall():IWall;
	function addWall(wall:IWall):void;
	function addSheet():void;
	
}
}