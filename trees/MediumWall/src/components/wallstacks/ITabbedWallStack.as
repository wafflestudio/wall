package components.wallstacks
{
import eventing.eventdispatchers.ICommitEventDispatcher;
import components.walls.IWall;

public interface ITabbedWallStack extends IWallStack
{
	function get selectedWall():IWall;
	function get selectedIndex():int;
	function set selectedIndex(val:int):void;

}
}