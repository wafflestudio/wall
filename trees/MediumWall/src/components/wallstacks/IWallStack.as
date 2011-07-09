package components.wallstacks
{
import components.IComponent;
import eventing.eventdispatchers.ISelectionChangeEventDispatcher;
import storages.IXMLizable;
import components.walls.IWall;
import eventing.eventdispatchers.ICommitEventDispatcher;

public interface IWallStack extends IComponent, ISelectionChangeEventDispatcher, ICommitEventDispatcher, IXMLizable
{
	function addWall(view:IWall):void;
	function removeWall(view:IWall):void;
}
}