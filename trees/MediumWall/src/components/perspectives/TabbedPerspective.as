package components.perspectives
{
import components.dialogs.IDialog;
import components.dialogs.OpenWallDialog;
import components.sheets.Sheet;
import components.toolbars.CommandToolbar;
import components.toolbars.ICommandToolbar;
import components.toolbars.IToolbar;
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
	private var tabStack:TabbedWallStack;
	private var vgroup:VGroup = new VGroup();
	private var option:String;
	public function TabbedPerspective(paths:Array = null)
	{	
		super();
		
		vgroup.percentHeight = 100;
		vgroup.percentWidth = 100;
				
		visualElement = vgroup;
		
		// toolbar
		toolbar = new CommandToolbar();
		addChildTo(vgroup, toolbar);
		
		//tabstack
		
		tabStack = new TabbedWallStack();
		
		tabStack.addSelectionChangeEventListener( function(e:SelectionChangeEvent):void {
			currentIndex = e.selectedIndex;
		});
		
		addChildTo(vgroup, tabStack);
		
		toolbar.newWallButton.addClickEventListener(
			function(e:ClickEvent):void {
				addWall(new FileStoredWall());
			}
		);
		
//		toolbar.openWallButton.addClickEventListener(
//			function(e:ClickEvent):void {
//				var dialog:IDialog = new OpenWallDialog();
//				dialog.show();
//			}
//		);


		toolbar.newImageButton.addClickEventListener(
			function(e:ClickEvent):void {
				option = "image";
				addSheet(option);
			}
		);
		
		toolbar.newSheetButton.addClickEventListener(
			function(e:ClickEvent):void {
				option = "text";
				addSheet(option);
			}
		);
		
		(toolbar as CommandToolbar).testButton.addClickEventListener(
			function(e:ClickEvent):void {
				
			}
		);
		
		tabStack.addCommitEventListener( function(e:CommitEvent):void
		{
			dispatchCommitEvent(e.actionName, e.args);
		});
	}
	
	private function setTabStack(tabStack:TabbedWallStack):void
	{
		if(this.tabStack)
			removeChildFrom(vgroup, tabStack);
		
		this.tabStack = tabStack;
		addChildTo(vgroup, tabStack);
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