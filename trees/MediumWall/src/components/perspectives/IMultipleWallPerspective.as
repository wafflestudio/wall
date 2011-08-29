package components.perspectives
{
import components.sheets.ISheet;
import components.walls.IWall;

import eventing.eventdispatchers.ISelectionChangeEventDispatcher;

public interface IMultipleWallPerspective extends IPerspective, ISelectionChangeEventDispatcher
{
	function get currentWall():IWall;
	function addWall(wall:IWall):void;
	function addSheet(option:String):void;
	
}
}