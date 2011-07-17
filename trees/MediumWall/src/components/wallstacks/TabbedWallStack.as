package components.wallstacks
{
import components.IComposite;
import mx.containers.TabNavigator;
import spark.components.BorderContainer;
import mx.core.IVisualElementContainer;
import spark.components.NavigatorContent;
import components.IComponent;
import components.Component;
import components.INameableComponent;
import eventing.events.NameChangeEvent;
import flash.events.Event;
import eventing.events.SelectionChangeEvent;
import eventing.events.CommitEvent;
import mx.events.IndexChangedEvent;
import components.walls.Wall;
import components.walls.IWall;
import mx.events.ChildExistenceChangedEvent;
import components.tabviews.TabView;
import storages.IXMLizable;
import components.walls.FileStoredWall;
import flash.filesystem.File;
import components.containers.Container;

public class TabbedWallStack extends TabView implements ITabbedWallStack
{	
	
	
	public function TabbedWallStack()
	{
		super();
		
		addSelectionChangeEventListener(function(e:SelectionChangeEvent):void
		{
			dispatchCommitEvent();
		});
	}
	
	public function addWall(wall:IWall):void
	{
		addChild(wall);
		dispatchCommitEvent();
	}
	
	public function removeWall(wall:IWall):void
	{
		removeChild(wall);	
		dispatchCommitEvent();
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

	
	public function get selectedWall():IWall
	{
		return selectedComponent as IWall;
	}
	
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
		for each(var wallXML:XML in xml.wall)
		{
			var wall:IWall;
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
			var wall:IWall = children[i] as IWall;
			xml.appendChild(wall.toXML());
		}
		
		return xml;
	}
	
	
}
}