package components.perspectives
{

import components.Component;
import components.ToplevelComponent;
import components.toolbars.CommandToolbar;
import components.walls.Wall;

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
	protected var toolbar:CommandToolbar;
	
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
	
	protected function dispatchCommitEvent(actionName:String, args:Array):void
	{
		dispatchEvent(new CommitEvent(this, actionName, args));
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