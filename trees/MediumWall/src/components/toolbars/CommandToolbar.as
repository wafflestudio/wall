package components.toolbars
{
import components.Component;
import components.IClickableComponent;
import components.buttons.Button;

import eventing.eventdispatchers.IClickEventDispatcher;
import eventing.eventdispatchers.IMouseEventDispatcher;

import flash.events.Event;

import mx.core.IVisualElement;

import spark.components.BorderContainer;
import spark.components.Group;
import spark.components.HGroup;

public class CommandToolbar extends Toolbar implements ICommandToolbar
{
	private var hgroup:HGroup;
	private var openWallBtn:Button;
	private var newWallBtn:Button;
	private var newSheetBtn:Button;
	private var testBtn:Button;
	private var newImageBtn:Button;
	
	// parent - (group - bg - hgroup) - children
	public function CommandToolbar()
	{
		var group:Group = new Group();
		group.percentWidth = 100;
		group.height = 48+16;
		
		var bg:BorderContainer = new BorderContainer();
		bg.percentHeight = 100;
		bg.percentWidth = 100;
		bg.setStyle("backgroundColor", 0xffffff);
		bg.setStyle("borderAlpha",0);
		group.addElement(bg);
		
		hgroup = new HGroup();
		hgroup.percentHeight = 100;
		hgroup.percentWidth = 100;
		bg.addElement(hgroup);
		
		visualElement = group;
		visualElementContainer = hgroup;
		
		openWallBtn = new Button();
		openWallBtn.label = "open wall";
		newWallBtn = new Button();
		newWallBtn.label = "new wall";
		newSheetBtn = new Button();
		newSheetBtn.label = "new sheet";
		
		testBtn = new Button();
		testBtn.label = "test";
		
		newImageBtn = new Button();
		newImageBtn.label = "new image sheet";
		
		addChild(openWallBtn);
		addChild(newWallBtn);
		addChild(newSheetBtn);
		addChild(testBtn);
		addChild(newImageBtn);
		
		
	}
	
	public function get openWallButton():IClickEventDispatcher
	{
		return openWallBtn;
	}
	
	public function get newWallButton():IClickEventDispatcher
	{
		return newWallBtn;
	}
	
	public function get newSheetButton():IClickEventDispatcher
	{
		return newSheetBtn;	
	}
	
	public function get testButton():IClickEventDispatcher
	{
		return testBtn;
	}
	public function get newImageButton():IClickEventDispatcher
	{
		return newImageBtn;
	}
}
}