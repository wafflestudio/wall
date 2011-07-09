package components.toolbars
{
import spark.components.BorderContainer;
import spark.components.HGroup;
import mx.controls.Image;
import components.IComposite;
import components.Component;
import mx.core.IVisualElement;
import components.buttons.Button;
import components.buttons.IButton;
import spark.components.Group;
import eventing.eventdispatchers.IMouseEventDispatcher;
import flash.events.Event;
import components.IClickableComponent;
import eventing.eventdispatchers.IClickEventDispatcher;

public class CommandToolbar extends Toolbar implements ICommandToolbar
{
	private var hgroup:HGroup;
	private var openWallBtn:IButton;
	private var newWallBtn:IButton;
	private var newSheetBtn:IButton;
	private var testBtn:IButton;
	
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
		
		addChild(openWallBtn);
		addChild(newWallBtn);
		addChild(newSheetBtn);
		addChild(testBtn);
		
		
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
	
}
}