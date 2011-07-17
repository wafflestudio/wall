package components.walls
{
import storages.IXMLizable;
import components.sheets.ISheet;
import spark.components.NavigatorContent;
import spark.components.Group;
import components.containers.ScrollableContainer;
import components.sheets.Sheet;
import flash.geom.Point;
import flash.display.DisplayObject;
import components.containers.PannableContainer;
import mx.core.IVisualElement;
import spark.components.BorderContainer;
import spark.components.Scroller;
import flash.events.MouseEvent;
import eventing.events.IFocusEvent;
import eventing.events.IDimensionChangeEvent;
import mx.core.IVisualElementContainer;
import eventing.events.NameChangeEvent;
import eventing.events.INameChangeEvent;
import eventing.events.IEvent;
import eventing.events.CommitEvent;
import eventing.events.ICommitEvent;

public class Wall extends PannableContainer implements IWall
{
	private var bc:BorderContainer = new BorderContainer();
	private var group:Group = new Group();
	
	override protected function get visualElement():IVisualElement  { return bc; }
	override protected function get visualElementContainer():IVisualElementContainer  { return group; }
	
	public function Wall()
	{
		super();
		
		bc.setStyle("borderAlpha", 0x0);
		bc.setStyle("backgroundColor", 0xF2F2F2);
		bc.percentHeight = 100;
		bc.percentWidth = 100;
		name = "wall";
		
		visualElement.addEventListener(MouseEvent.MOUSE_WHEEL,function(e:MouseEvent):void {
			var multiplier:Number = Math.pow(1.03, e.delta);
			
			zoom = multiplier;
			dispatchDimensionChangeEvent(extent, extent);
			dispatchChildrenDimensionChangeEvent();
			dispatchCommitEvent();
		});
		
		addNameChangeEventListener( function(e:IEvent):void  {
			dispatchCommitEvent();
		});
		
		addChildAddedEventListener(function():void  {
			dispatchChildrenDimensionChangeEvent();
			dispatchCommitEvent();
		});
		
		addChildRemovedEventListener(function():void  {
			dispatchChildrenDimensionChangeEvent();
			dispatchCommitEvent();
		});
		
		
	}
	
	
	
	public function addBlankSheet():void
	{
		var sheet:ISheet = new Sheet();
		
		var compCenter:Point = new Point(width/2, height/2);
		
		var center:Point = (visualElementContainer as DisplayObject).globalToLocal(localToGlobal(compCenter));
		
		sheet.width = 300;
		sheet.height = 400;
		sheet.x = center.x-sheet.width/2;
		sheet.y = center.y-sheet.height/2;
		
		addSheet(sheet);
	}
	
	private function onSheetCommitEvent(e:IEvent):void
	{
		dispatchCommitEvent();
	}
	
	private function onSheetFocusEvent(e:IFocusEvent):void 
	{
		bringToFront(e.target as Sheet);
	}
	
	public function addSheet(sheet:ISheet):void
	{
		sheet.addFocusInEventListener(onSheetFocusEvent); 
		sheet.addCommitEventListener(onSheetCommitEvent);
		addChild(sheet);
	}
	
	public function removeSheet(sheet:ISheet):void
	{
		removeChild(sheet);
		sheet.removeCommitEventListener(onSheetCommitEvent);
		sheet.removeFocusInEventListener(onSheetFocusEvent);
	}
		
	
	
	
	
	private var _name:String = "noname";
	
	public function get name():String  { return _name; }
	public function set name(val:String):void  { _name = val; dispatchNameChangeEvent(new NameChangeEvent(null, val));}
	
	public function addNameChangeEventListener(listener:Function):void
	{
		addEventListener(NameChangeEvent.NAME_CHANGE, listener);	
	}
	
	public function removeNameChangeEventListener(listener:Function):void
	{
		removeEventListener(NameChangeEvent.NAME_CHANGE, listener);	
	}
	
	protected function dispatchNameChangeEvent(e:INameChangeEvent):void
	{
		dispatchEvent(e);	
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
	 * 	<wall>
	 * 		<sheets>
	 * 			<sheet></sheet>
	 * 		</sheets>
	 * 	</wall>
	 */
	public function fromXML(xml:XML):IXMLizable
	{	
		reset();
		
		if(xml.@name)
			name = xml.@name;
		if(xml.@panX)
			_panX = xml.@panX;
		if(xml.@panY)
			_panY = xml.@panY;
		if(xml.@zoomX)
			_zoomX = xml.@zoomX;
		if(xml.@zoomY)
			_zoomY = xml.@zoomY;
		
		for each(var sheetXML:XML in xml.sheets[0].sheet)
		{
			var sheet:ISheet = new Sheet();
			sheet.fromXML(sheetXML);
			addSheet(sheet);
		}
		
		return this;
	}
	
	
	public function toXML():XML
	{
		var xml:XML = <wall/>;
		trace(xml.@zoomX);
		xml.@name = name;
		xml.@panX = panX;
		xml.@panY = panY;
		xml.@zoomX = zoomX;
		xml.@zoomY = zoomY;
		
		var sheetsXML:XML = <sheets/>
		for(var i:int = 0; i < numChildren; i++)
		{
			var sheet:ISheet = children[i] as ISheet;
			sheetsXML.appendChild(sheet.toXML());
		}
		xml.appendChild(sheetsXML);
		return xml;
	}
	
	
	
	
	
}
}