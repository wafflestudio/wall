package components.wallstacks
{
import components.Component;
import components.IComponent;
import components.INameableComponent;
import components.containers.Container;
import components.tabviews.TabView;
import components.walls.FileStoredWall;
import components.walls.Wall;

import eventing.eventdispatchers.IEventDispatcher;
import eventing.events.CommitEvent;
import eventing.events.NameChangeEvent;
import eventing.events.SelectionChangeEvent;

import flash.events.Event;
import flash.filesystem.File;

import mx.containers.TabNavigator;
import mx.core.IVisualElementContainer;
import mx.events.ChildExistenceChangedEvent;
import mx.events.IndexChangedEvent;

import spark.components.BorderContainer;
import spark.components.NavigatorContent;

import storages.IXMLizable;

public class TabbedWallStack extends TabView implements IWallStack
{	
	
	
	public function TabbedWallStack()
	{
		super();
		
		addSelectionChangeEventListener(function(e:SelectionChangeEvent):void
		{
			dispatchCommitEvent(self, "SELECTION_CHANGE", [e.selectedIndex]);
		});
	}
	
	public function addWall(wall:Wall):void
	{
		addChild(wall);
		dispatchCommitEvent(self, "ADDED_WALL", [wall]);
	}
	
	public function removeWall(wall:Wall):void
	{
		removeChild(wall);	
		dispatchCommitEvent(self, "REMOVED_WALL", [wall]);
	}
	
	
	override protected function addChildTo(visualElementContainer:IVisualElementContainer, component:IComponent):void
	{
		var nameablecomp:INameableComponent = component as INameableComponent;
			
		var nc:NavigatorContent = new NavigatorContent();
		visualElementContainer.addElement(nc);
		super.addChildTo(nc, component);
		
		if(nameablecomp)  {
			nc.label = nameablecomp.name;	
			nameablecomp.addNameChangeEventListener( function(e:NameChangeEvent):void
				{
					nc.label = e.name;		
				}
			);
		}
	}
	
	override protected function removeChildFrom(visualElementContainer:IVisualElementContainer, component:IComponent):void
	{
		var nameablecomp:INameableComponent = component as INameableComponent;
			
		var nc:NavigatorContent = removeFromParent(component as Component) as NavigatorContent;
		visualElementContainer.removeElement(nc);	
		
		if(nameablecomp)
			removeAllEventListeners(NameChangeEvent.NAME_CHANGE);
		
	}

	
	public function get selectedWall():Wall
	{
		return selectedComponent as Wall;
	}
	
	public function addCommitEventListener(listener:Function):void
	{
		addEventListener(CommitEvent.COMMIT, listener);	
	}
	
	public function removeCommitEventListener(listener:Function):void
	{
		removeEventListener(CommitEvent.COMMIT, listener);	
	}
	
	protected function dispatchCommitEvent(dispatcher:IEventDispatcher, actionName:String, args:Array):void
	{
		dispatchEvent(new CommitEvent(dispatcher, actionName, args));
	}
	
	
	
	
	/**
	 * 	<walls>
	 * 		<wall></wall>
	 * 		<wall></wall>
	 * 	</walls>
	 * 
	 */
	public function fromXML(xml:XML):IXMLizable
	{
		reset();
		if(xml.wall)
		for each(var wallXML:XML in xml.wall)
		{
			var wall:Wall;
			if(wallXML.@file)
				wall = new FileStoredWall(new File(wallXML.@file.toString()));
			else  {
				wall = new Wall();
				wall.fromXML(wallXML);
			}
			
			addWall(wall);
			var c:Container;
			
			
		}
		
		selectedIndex = xml.@selectedIndex;
		
		return this;
	}
	
	public function toXML():XML
	{
		var xml:XML = <walls/>;
		xml.@selectedIndex = selectedIndex;
		for(var i:int = 0; i < numChildren; i++)
		{
			var wall:Wall = children[i] as Wall;
			xml.appendChild(wall.toXML());
		}
		
		return xml;
	}
	
	
}
}