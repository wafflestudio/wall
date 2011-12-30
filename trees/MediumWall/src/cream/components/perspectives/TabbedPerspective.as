package cream.components.perspectives
{
import cream.components.toolbars.CommandToolbar;
import cream.components.walls.Wall;
import cream.components.wallstacks.TabbedWallStack;
import cream.eventing.events.CommitEvent;
import cream.eventing.events.SelectionChangeEvent;
import cream.storages.IXMLizable;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import spark.components.VGroup;



public class TabbedPerspective extends MultipleWallPerspective implements IXMLizable
{
    // Spark Elements: vgroup -> [toolbar, group -> [tabstack]]
	public var toolbar:CommandToolbar;
	private var tabStack:TabbedWallStack;
	private var vgroup:VGroup = new VGroup();
	private var group:VGroup = new VGroup();

    override protected function get visualElement():IVisualElement {  return vgroup;  }
    override protected function get visualElementContainer():IVisualElementContainer	{  return group;	}
	
	public function TabbedPerspective(paths:Array = null)
	{	
		super();

	}

    override protected function initUnderlyingComponents():void
    {
        vgroup = new VGroup();
        group = new VGroup();
        tabStack = new TabbedWallStack();
        toolbar = new CommandToolbar();

        vgroup.percentHeight = 100;
        vgroup.percentWidth = 100;

        group.percentHeight = 100;
        group.percentWidth = 100;


        // force add toolbar
        vgroup.addElement(toolbar._protected_::visualElement);
        vgroup.addElement(group);

        //tabstack

        tabStack.percentHeight = 100;
        tabStack.percentWidth = 100;

        tabStack.addSelectionChangeEventListener( function(e:SelectionChangeEvent):void {
            currentIndex = e.selectedIndex;
        });

        tabStack.addCommitEventListener( function(e:CommitEvent):void
        {
            dispatchCommitEvent(e);
        });

        addChild( tabStack );
    }
	
	private function setTabStack(tabStack:TabbedWallStack):void
	{
		if(tabStack)
			removeChild(tabStack);
		
		tabStack = tabStack;
		addChild(tabStack);
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