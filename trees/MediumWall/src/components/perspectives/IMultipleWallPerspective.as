package components.perspectives
{
import components.walls.Wall;

import eventing.eventdispatchers.ISelectionChangeEventDispatcher;

public interface IMultipleWallPerspective extends IPerspective, ISelectionChangeEventDispatcher
{
	function get currentWall():Wall;
	function addWall(wall:Wall):void;
	function addSheet(option:String):void;
	
}
}