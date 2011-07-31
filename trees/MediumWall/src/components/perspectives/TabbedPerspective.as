package components.perspectives
{
import spark.components.Group;
import mx.containers.ViewStack;
import storages.IXMLizable;
import components.sheets.ISheet;
import storages.sessions.ISession;
import components.walls.IWall;
import components.toolbars.IToolbar;
import components.toolbars.Toolbar;
import spark.components.VGroup;
import components.toolbars.CommandToolbar;
import components.wallstacks.ITabbedWallStack;
import components.wallstacks.TabbedWallStack;
import components.toolbars.ICommandToolbar;
import eventing.eventdispatchers.IClickEventDispatcher;
import eventing.events.Event;
import components.walls.Wall;
import mx.managers.PopUpManager;
import components.dialogs.OpenWallDialog;
import components.dialogs.IDialog;
import components.sheets.Sheet;
import flash.geom.Point;
import flash.display.DisplayObject;
import components.walls.FileStoredWall;
import eventing.events.SelectionChangeEvent;
import eventing.events.ClickEvent;



public class TabbedPerspective extends MultipleWallPerspective implements IXMLizable
{
	private var tabStack:ITabbedWallStack;
	private var vgroup:VGroup = new VGroup();
	
	public function TabbedPerspective()
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
		
		toolbar.newSheetButton.addClickEventListener(
			function(e:ClickEvent):void {
				addSheet();
			}
		);
		
		(toolbar as CommandToolbar).testButton.addClickEventListener(
			function(e:ClickEvent):void {
				trace(toXML());		
			}
		);
		
		tabStack.addCommitEventListener( function():void
		{
			dispatchCommitEvent();
		});
	}
	
	private function setTabStack(tabStack:ITabbedWallStack):void
	{
		if(this.tabStack)
			removeChildFrom(vgroup, tabStack);
		
		this.tabStack = tabStack;
		addChildTo(vgroup, tabStack);
	}

	override public function get currentWall():IWall
	{
		return tabStack.selectedWall;	
	}
	
	override public function addWall(wall:IWall):void
	{
		super.addWall(wall);
		tabStack.addChild(wall);
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