package components.perspectives
{
import components.IComponent;
import components.IToplevelComponent;
import components.sheets.ISheet;
import components.walls.IWall;
import storages.IXMLizable;
import eventing.eventdispatchers.IClickEventDispatcher;
import eventing.eventdispatchers.IChangeEventDispatcher;
import eventing.eventdispatchers.ICommitEventDispatcher;

public interface IPerspective extends IComponent, IToplevelComponent, IXMLizable, ICommitEventDispatcher
{
	
}
}