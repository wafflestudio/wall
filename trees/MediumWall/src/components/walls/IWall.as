package components.walls
{
import components.containers.IScrollableContainer;
import storages.IXMLizable;
import components.sheets.ISheet;
import components.containers.IPannableContainer;
import components.INameableComponent;
import eventing.eventdispatchers.ICommitEventDispatcher;
import components.ICommitableComponent;

public interface IWall extends IPannableContainer, IXMLizable, INameableComponent, ICommitableComponent
{
	function addBlankSheet():void;
	function addSheet(sheet:ISheet):void;
}
}