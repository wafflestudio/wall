package cream.components.perspectives
{

import cream.components.Component;
import cream.components.ToplevelComponent;
import cream.components.toolbars.CommandToolbar;
import cream.components.walls.Wall;

import cream.eventing.eventdispatchers.IClickEventDispatcher;
import cream.eventing.eventdispatchers.ICommitEventDispatcher;
import cream.eventing.events.CommitEvent;
import cream.eventing.events.Event;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import spark.components.Application;

import cream.storages.IXMLizable;

public class Perspective extends ToplevelComponent implements  IXMLizable, ICommitEventDispatcher
{	
	
	public function Perspective()
	{
        super();
	}

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