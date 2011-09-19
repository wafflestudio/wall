package components.wallstacks
{
import components.Component;
import components.Composite;
import components.IComponent;
import components.INameableComponent;
import components.containers.Container;
import components.tabviews.TabView;
import components.walls.FileStoredWall;
import components.walls.Wall;

import eventing.eventdispatchers.ICommitEventDispatcher;
import eventing.eventdispatchers.IEventDispatcher;
import eventing.eventdispatchers.ISelectionChangeEventDispatcher;
import eventing.events.ActionCommitEvent;
import eventing.events.CommitEvent;
import eventing.events.CompositeEvent;
import eventing.events.FocusEvent;
import eventing.events.NameChangeEvent;
import eventing.events.SelectionChangeEvent;

import flash.events.Event;
import flash.filesystem.File;

import mx.containers.TabNavigator;
import mx.core.IVisualElementContainer;
import mx.events.IndexChangedEvent;

import spark.components.BorderContainer;
import spark.components.NavigatorContent;

import storages.IXMLizable;
import storages.actions.Action;
import storages.actions.IActionCommitter;

public class TabbedWallStack extends TabView implements IComponent, ISelectionChangeEventDispatcher, ICommitEventDispatcher, IXMLizable, IActionCommitter
{	
	/** actions **/
	protected static const ADDED_WALL:String = "ADDED_WALL";
	protected static const REMOVED_WALL:String = "REMOVED_WALL";
	protected static const SELECTION_CHANGE:String = "SELECTION_CHANGE"; 
	
	public function TabbedWallStack()
	{
		super();
		
		addSelectionChangeEventListener(function(e:SelectionChangeEvent):void
		{
			dispatchCommitEvent(new CommitEvent(self, SELECTION_CHANGE, [e.oldSelectedIndex, e.selectedIndex]));
		});
		
		addChildRemovedEventListener( function(e:CompositeEvent):void 
		{
			/** action commit **/
			dispatchCommitEvent(new ActionCommitEvent(self, REMOVED_WALL, [e.child]));
		});
		
		addChildAddedEventListener( function(e:CompositeEvent):void
		{
			/** action commit **/
			dispatchCommitEvent(new ActionCommitEvent(self, ADDED_WALL, [e.child]));
		});
	}
	
	private function onWallCommit(e:CommitEvent):void
	{
		dispatchCommitEvent(e);	
	}
	
	private function onWallFocusIn(e:FocusEvent):void
	{
		if(selectedComponent != e.dispatcher)
		{
			for(var i:int = 0; i < children.length; i++)  {
				if(children[i] == e.dispatcher)  {
					selectedIndex = i;
					return;
				}
			}
		}
	}
	
	protected override function addChild(child:Composite):Composite
	{
		super.addChild(child);
		(child as Wall).addCommitEventListener(onWallCommit);
		(child as Wall).addFocusInEventListener(onWallFocusIn);
		
		return child;
	}
	
	protected override function removeChild(child:Composite):Composite
	{
		var wall:Wall = child as Wall;
		wall.removeCommitEventListener(onWallCommit);
		wall.removeFocusInEventListener(onWallFocusIn);
		return super.removeChild(child);
	}
	
	public function addWall(wall:Wall):void
	{
		addChild(wall);
	}
	
	public function removeWall(wall:Wall):void
	{
		removeChild(wall);
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
	
	protected function dispatchCommitEvent(e:CommitEvent):void
	{
		dispatchEvent(e);
	}
	
	
	
	public function applyAction(action:Action):void
	{
		switch(action.type)
		{
			case ADDED_WALL:
				addWall(action.args[0] as Wall);
				break;
			case REMOVED_WALL:
				removeWall(action.args[0] as Wall);
				break;
		}
	}
	
	public function revertAction(action:Action):void
	{
		switch(action.type)
		{
			case ADDED_WALL:
				removeWall(action.args[0] as Wall);
				break;
			case REMOVED_WALL:
				addWall(action.args[0] as Wall);
				break;
		}
		
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