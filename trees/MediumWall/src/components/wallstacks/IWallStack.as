package components.wallstacks
{
import components.IComponent;
import components.walls.Wall;

import eventing.eventdispatchers.ICommitEventDispatcher;
import eventing.eventdispatchers.ISelectionChangeEventDispatcher;

import storages.IXMLizable;

public interface IWallStack extends IComponent, ISelectionChangeEventDispatcher, ICommitEventDispatcher, IXMLizable
{
	function addWall(view:Wall):void;
	function removeWall(view:Wall):void;
}
}