package components.walls
{
import components.ICommitableComponent;
import components.INameableComponent;
import components.IToplevelComponent;
import components.containers.IPannableContainer;
import components.containers.IScrollableContainer;
import components.sheets.ISheet;

import eventing.eventdispatchers.ICommitEventDispatcher;

import storages.IXMLizable;

public interface IWall extends IPannableContainer, IXMLizable, INameableComponent, ICommitableComponent, IToplevelComponent
{
	function addBlankSheet(option:String=null):void;
	function addSheet(sheet:ISheet):void;
}
}