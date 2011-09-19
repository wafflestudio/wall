package cream.components.perspectives
{

import cream.components.Component;
import cream.components.ToplevelComponent;
import cream.components.toolbars.CommandToolbar;
import cream.components.walls.Wall;

import eventing.eventdispatchers.IClickEventDispatcher;
import eventing.eventdispatchers.ICommitEventDispatcher;
import eventing.events.CommitEvent;
import eventing.events.Event;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import spark.components.Application;

import storages.IXMLizable;

public class Perspective extends ToplevelComponent implements  IXMLizable, ICommitEventDispatcher
{	
	
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
	
	protected function dispatchCommitEvent(e:CommitEvent):void
	{
		dispatchEvent(e);
	}


	public function fromXML(xml:XML):IXMLizable
	{
		return null;
	}
	
	public function toXML():XML
	{
		return null;
	}
	
	public function get defaultXML():XML
	{
		return null;
	}
	
}
}