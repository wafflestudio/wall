package cream.components.walls
{
import cream.components.ICommitableComponent;
import cream.components.INameableComponent;
import cream.components.IToplevelComponent;
import cream.components.containers.IPannableContainer;
import cream.components.containers.PannableContainer;
import cream.components.containers.ScrollableContainer;
import cream.components.sheets.Sheet;

import eventing.eventdispatchers.IEventDispatcher;
import eventing.eventdispatchers.IZoomEventDispatcher;
import eventing.events.ActionCommitEvent;
import eventing.events.CloseEvent;
import eventing.events.CommitEvent;
import eventing.events.CompositeEvent;
import eventing.events.Event;
import eventing.events.FocusEvent;
import eventing.events.NameChangeEvent;
import eventing.events.PanEvent;
import eventing.events.ZoomEvent;

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import spark.components.BorderContainer;
import spark.components.Group;
import spark.components.NavigatorContent;
import spark.components.Scroller;

import storages.IXMLizable;
import storages.actions.Action;
import storages.actions.IActionCommitter;



public class Wall extends PannableContainer implements IPannableContainer, IXMLizable, INameableComponent, ICommitableComponent, 
	IToplevelComponent, IZoomEventDispatcher, IActionCommitter
{
	/** Available Actions  **/
	public static const ZOOM_CHANGED:String = "zoomChanged";
	public static const PANNED:String = "Panned";
	public static const NAME_CHANGED:String = "nameChanged";
	public static const SHEET_ADDED:String = "sheetAdded";
	public static const SHEET_REMOVED:String = "sheetRemoved";
	
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
		
		// wheel scroll to zoom
		visualElement.addEventListener(MouseEvent.MOUSE_WHEEL,function(e:MouseEvent):void {
			var multiplier:Number = Math.pow(1.03, e.delta);
			var oldZoomX:Number = _zoomX;
			var oldZoomY:Number = _zoomY;
			
			zoom = multiplier;
			dispatchDimensionChangeEvent(extent, extent);
			dispatchChildrenDimensionChangeEvent();
			dispatchZoomEvent(oldZoomX, oldZoomY, _zoomX, _zoomY);
		});
		
		// ignore consecutive zoom as a commit. commit only the last one
		var delayedZoomTimer:Timer = new Timer(300, 1);
		var zoomArgs:Array = [];
		
		delayedZoomTimer.addEventListener(TimerEvent.TIMER, function():void
		{
			dispatchCommitEvent(new CommitEvent(self, ZOOM_CHANGED, zoomArgs));
		});
		
		addZoomedEventListener( function(e:ZoomEvent):void {
			zoomArgs = [e.oldZoomX, e.oldZoomY, e.zoomX, e.zoomY];
			delayedZoomTimer.reset();
			delayedZoomTimer.start();
		});
		
		
		
		addPannedEventListener( function(e:PanEvent):void {
			dispatchCommitEvent(new CommitEvent(self, PANNED, [e.oldX, e.oldY, e.newX, e.newY]));
		});
		
		addNameChangeEventListener( function():void  {
			dispatchCommitEvent(new CommitEvent(self, NAME_CHANGED, [name]));
		});
		
		addChildAddedEventListener(function(e:CompositeEvent):void  {
			dispatchChildrenDimensionChangeEvent();
			dispatchCommitEvent(new ActionCommitEvent(self, SHEET_ADDED, [e.child]));
		});
		
		addChildRemovedEventListener(function(e:CompositeEvent):void  {
			dispatchChildrenDimensionChangeEvent();
			dispatchCommitEvent(new ActionCommitEvent(self, SHEET_REMOVED, [e.child]));
		});
		
		
	}
	
	
	
	public function addBlankSheet(type:String=Sheet.TEXT_SHEET):void
	{
		var sheet:Sheet = new Sheet(type);
		var compCenter:Point = new Point(width/2, height/2);
		
		var center:Point = (visualElementContainer as DisplayObject).globalToLocal(localToGlobal(compCenter));
		
		sheet.width = 300;
		sheet.height = 400;
		sheet.x = center.x-sheet.width/2;
		sheet.y = center.y-sheet.height/2;
		
		addSheet(sheet);
	}
	
	private function onSheetCommitEvent(e:CommitEvent):void
	{
		dispatchCommitEvent(e);
	}
	
	private function onSheetFocusEvent(e:FocusEvent):void 
	{
		bringToFront(e.target as Sheet);
	}
	
	private function onSheetClose(e:CloseEvent):void
	{
		removeSheet(e.dispatcher as Sheet);
	}
	
	public function addSheet(sheet:Sheet):void
	{
		sheet.addFocusInEventListener(onSheetFocusEvent); 
		sheet.addCommitEventListener(onSheetCommitEvent);
		sheet.addCloseEventListener(onSheetClose);
		addChild(sheet);
	}
	
	public function removeSheet(sheet:Sheet):void
	{
		removeChild(sheet);
		sheet.removeCloseEventListener(onSheetClose);
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
	
	protected function dispatchNameChangeEvent(e:NameChangeEvent):void
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
	
	public function addZoomedEventListener(listener:Function):void
	{
		addEventListener(ZoomEvent.ZOOM, listener);
	}
	
	public function removeZoomedEventListener(listener:Function):void
	{
		removeEventListener(ZoomEvent.ZOOM, listener);	
	}
	
	
	
	protected function dispatchCommitEvent(e:CommitEvent):void
	{
		dispatchEvent(e);	
	}
	
	protected function dispatchZoomEvent(oldZoomX:Number, oldZoomY:Number, zoomX:Number, zoomY:Number):void
	{
		dispatchEvent(new ZoomEvent(this, oldZoomX, oldZoomY, zoomX, zoomY));	
	}
	
	
	public function addToApplication(app:IVisualElementContainer = null):void
	{
		app.addElement(visualElement);
	}
	
	public function removeFromApplication(app:IVisualElementContainer = null):void
	{
		if(app)
			app.removeElement(visualElement);
		else
			(visualElement.parent as IVisualElementContainer).removeElement(visualElement);
	}
	
	
	public function applyAction(action:Action):void
	{
		switch(action.type)
		{
			case SHEET_ADDED:
				addSheet(action.args[0] as Sheet);
				break;
			case SHEET_REMOVED:
				removeSheet(action.args[0] as Sheet);
				break;
		}
	}
	
	public function revertAction(action:Action):void
	{
		switch(action.type)
		{
			case SHEET_ADDED:
				removeSheet(action.args[0] as Sheet);
				break;
			case SHEET_REMOVED:
				addSheet(action.args[0] as Sheet);
				break;
		}
		
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
			var sheet:Sheet = new Sheet(sheetXML.@type);
			sheet.fromXML(sheetXML);
			addSheet(sheet);
		}
		
		return this;
	}
	
	
	public function toXML():XML
	{
		var xml:XML = <wall/>;
		xml.@name = name;
		xml.@panX = panX;
		xml.@panY = panY;
		xml.@zoomX = zoomX;
		xml.@zoomY = zoomY;
		
		var sheetsXML:XML = <sheets/>
		for(var i:int = 0; i < numChildren; i++)
		{
			var sheet:Sheet = children[i] as Sheet;
			sheetsXML.appendChild(sheet.toXML());
		}
		xml.appendChild(sheetsXML);
		return xml;
	}
	
	
	
	
	
}
}