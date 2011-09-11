package components.perspectives
{
import components.dialogs.Dialog;
import components.dialogs.OpenWallDialog;
import components.sheets.Sheet;
import components.toolbars.CommandToolbar;
import components.toolbars.Toolbar;
import components.walls.FileStoredWall;
import components.walls.Wall;
import components.wallstacks.TabbedWallStack;
import eventing.eventdispatchers.IClickEventDispatcher;
import eventing.events.ClickEvent;
import eventing.events.CommitEvent;
import eventing.events.Event;
import eventing.events.SelectionChangeEvent;
import flash.display.DisplayObject;
import flash.geom.Point;
import mx.containers.ViewStack;
import mx.managers.PopUpManager;

import spark.components.Group;
import spark.components.VGroup;

import storages.IXMLizable;



public class TabbedPerspective extends MultipleWallPerspective implements IXMLizable
{
	public var toolbar:CommandToolbar = new CommandToolbar();
	private var tabStack:TabbedWallStack;
	private var vgroup:VGroup = new VGroup();
	
	public function TabbedPerspective(paths:Array = null)
	{	
		super();
		
		vgroup.percentHeight = 100;
		vgroup.percentWidth = 100;
				
		visualElement = vgroup;
		
		// toolbar
		vgroup.addElement(toolbar._protected_::visualElement);
		
		//tabstack
		tabStack = new TabbedWallStack();
		
		tabStack.addSelectionChangeEventListener( function(e:SelectionChangeEvent):void {
			currentIndex = e.selectedIndex;
		});
		
		vgroup.addElement(tabStack._protected_::visualElement);
		
		tabStack.addCommitEventListener( function(e:CommitEvent):void
		{
			dispatchCommitEvent(e);
		});
	}
	
	private function setTabStack(tabStack:TabbedWallStack):void
	{
		if(this.tabStack)
			vgroup.removeElement(tabStack._protected_::visualElement);
			
		
		this.tabStack = tabStack;
		vgroup.addElement(tabStack._protected_::visualElement);
		
	}

	override public function get currentWall():Wall
	{
		return tabStack.selectedWall;	
	}
	
	override public function addWall(wall:Wall):void
	{
		super.addWall(wall);
		tabStack.addWall(wall);
	}
	
	/**
	 * <perspective>
	 * 	<walls>
	 *    // walls
	 * 	</walls>
	 * </perspective>
	 */
	override public function fromXML(xml:XML):IXMLizable
	{
		reset();
		if(xml.walls && xml.walls[0])
			tabStack.fromXML(xml.walls[0]);
		
		return this;
	}
	
	override public function toXML():XML
	{
		var xml:XML = <perspective/>;
		
		var wallsXML:XML = tabStack.toXML();
		
		xml.appendChild(wallsXML);
		
		return xml;
	}
	
	public static function get defaultXML():XML
	{
		var xml:XML = <perspective/>;
		
		var walls:XML = <walls/>;
		
		xml.appendChild(walls);
		
		return xml;
	}
	
	override protected function get currentIndex():int
	{
		return tabStack.selectedIndex;		
	}
	
	override protected function set currentIndex(val:int):void
	{
		tabStack.selectedIndex = val;
	}
	
}
}