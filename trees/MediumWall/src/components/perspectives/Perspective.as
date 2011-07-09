package components.perspectives
{

import spark.components.Application;
import mx.core.IVisualElement;
import components.Component;
import components.ToplevelComponent;
import components.sheets.ISheet;
import components.walls.IWall;
import components.walls.Wall;
import storages.IXMLizable;
import mx.core.IVisualElementContainer;
import components.toolbars.ICommandToolbar;
import eventing.eventdispatchers.IClickEventDispatcher;
import eventing.events.Event;
import eventing.events.CommitEvent;

public class Perspective extends ToplevelComponent implements IPerspective
{	
	protected var toolbar:ICommandToolbar;
	
	public function Perspective()
	{
		
	}
	
	override protected function set visualElementContainer(val:IVisualElementContainer):void { }
	override protected function get visualElementContainer():IVisualElementContainer { return null; }
	
	public function addCommitEventListener(listener:Function):void
	{
		addEventListener(CommitEvent.COMMIT, listener);	
	}
	
	public function removeCommitEventListener(listener:Function):void
	{
		removeEventListener(CommitEvent.COMMIT, listener);	
	}
	
	protected function dispatchCommitEvent():void
	{
		dispatchEvent(new CommitEvent(this));
	}


	public function fromXML(xml:XML):IXMLizable
	{
		return this;
	}
	
	public function toXML():XML
	{
		var xml:XML = <perspective/>;
		
		var walls:XML = <walls/>;
		
		xml.appendChild(walls);
		
		return xml;
	}
	
	public static function get defaultXML():XML
	{
		var xml:XML = <perspective/>;
		
		var walls:XML = <walls/>;
		
		xml.appendChild(walls);
		
		return xml;
	}
	
}
}