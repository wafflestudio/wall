package cream.components.walls
{
import cream.components.Component;
import cream.components.ICommitableComponent;
import cream.components.INameableComponent;
import cream.components.IToplevelComponent;
import cream.components.containers.IPannableContainer;
import cream.components.containers.PannableContainer;
import cream.components.sheets.Sheet;
import cream.eventing.eventdispatchers.IClipboardPasteEventDispatcher;
import cream.eventing.eventdispatchers.IZoomEventDispatcher;
import cream.eventing.events.ActionCommitEvent;
import cream.eventing.events.ClipboardEvent;
import cream.eventing.events.CloseEvent;
import cream.eventing.events.CommitEvent;
import cream.eventing.events.CompositeEvent;
import cream.eventing.events.FocusEvent;
import cream.eventing.events.MoveEvent;
import cream.eventing.events.NameChangeEvent;
import cream.eventing.events.PanEvent;
import cream.eventing.events.ZoomEvent;
import cream.storages.IXMLizable;
import cream.storages.actions.Action;
import cream.storages.actions.IActionCommitter;
import cream.utils.TemporaryFileStorage;
import cream.utils.XMLFileStream;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;

import flash.utils.ByteArray;
import flash.utils.Timer;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.graphics.codec.PNGEncoder;

import spark.components.BorderContainer;
import spark.components.Group;


public class Wall extends PannableContainer implements IPannableContainer, IXMLizable, INameableComponent, ICommitableComponent, 
	IToplevelComponent, IZoomEventDispatcher, IActionCommitter, IClipboardPasteEventDispatcher
{
	/** Available Actions  **/
	public static const ZOOM_CHANGED:String = "zoomChanged";
	public static const PANNED:String = "Panned";
	public static const NAME_CHANGED:String = "nameChanged";
	public static const SHEET_ADDED:String = "sheetAdded";
	public static const SHEET_REMOVED:String = "sheetRemoved";
	
	public static const DEFAULT_SHEET_SIZE:Number = 300;
	
	
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
		
		
		
		// wheel scroll to zoom
		visualElement.addEventListener(MouseEvent.MOUSE_WHEEL,function(e:MouseEvent):void {
			setZoom(zoomX* Math.pow(1.03,e.delta));
			
		});
		
		/** focus when wall clicked **/
		visualElement.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
		{
			if(e.target.parent != visualElement)
				return;
			
			for each(var child:Component in children)  {
				child._protected_::dispatchFocusOutEvent();
			}
			dispatchFocusInEvent();
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
			dispatchCommitEvent(new ActionCommitEvent(self, SHEET_ADDED, [e.child]));
		});
		
		addChildRemovedEventListener(function(e:CompositeEvent):void  {
			dispatchCommitEvent(new ActionCommitEvent(self, SHEET_REMOVED, [e.child]));
		});
		
		addPasteEventListener( function(e:ClipboardEvent):void
		{
			if(e.format == ClipboardEvent.TEXT_FORMAT) {
				addTextSheet(e.object as String);
			} else if(e.format == (ClipboardEvent.BITMAP_FORMAT)) {
				
				var imageFile:File = null;
				var encoder:PNGEncoder = new PNGEncoder();
				var bitmapData:BitmapData = e.object as BitmapData;
				var rawBytes:ByteArray = encoder.encode(bitmapData);
				imageFile = TemporaryFileStorage.imageAssetsResolve("png",File.applicationStorageDirectory.resolvePath(name));
				var fileStream:FileStream = new FileStream();
				fileStream.open( imageFile, FileMode.WRITE );
				fileStream.writeBytes( rawBytes );
				fileStream.close();
				addImageSheet(imageFile, bitmapData.width, bitmapData.height );
			}
		});


		
	}
	
	public function setZoom(_multiplier:Number):void {
		var multiplier:Number = _multiplier;
		var oldZoomX:Number = _zoomX;
		var oldZoomY:Number = _zoomY;
		
		zoom = multiplier;
		dispatchDimensionChangeEvent(extent, extent);
		dispatchChildrenDimensionChangeEvent();
		dispatchZoomEvent(oldZoomX, oldZoomY, _zoomX, _zoomY);
	}
	
	public function addTextSheet(text:String = "", width:Number = 0, height:Number = 0):void
	{
		var sheet:Sheet = Sheet.createTextSheet(text);
		width = width == 0 ? DEFAULT_SHEET_SIZE : width;
		height = height == 0 ? DEFAULT_SHEET_SIZE : height;
		
		addNewSheetAtCenter(sheet, width, height);
	}
	
	public function addImageSheet(imageFile:File = null, width:Number = 0, height:Number = 0):void
	{
		var sheet:Sheet = Sheet.createImageSheet(imageFile);
		width = width == 0 ? DEFAULT_SHEET_SIZE : width;
		height = height == 0 ? DEFAULT_SHEET_SIZE : height;
		
		addNewSheetAtCenter(sheet, width, height);
	}
	
	
	protected function addNewSheetAtCenter(sheet:Sheet, width:Number, height:Number):void
	{
		var compCenter:Point = new Point(this.width/2, this.height/2);
		var globalCenter:Point = (visualElement as DisplayObject).localToGlobal(compCenter);
		var center:Point = globalToLocal(globalCenter);
		var dimension:Point = (visualElement as DisplayObject).globalToLocal(localToGlobal(new Point(width, height))).subtract(
			(visualElement as DisplayObject).globalToLocal(localToGlobal(new Point(0,0))));
		
		// resize if image is too big
		if(dimension.x > this.width*2/3) {
			var ratio:Number = height/width;
			var adjustedDimension:Point = globalToLocal(new Point(this.width*5/6, this.width*5/6*ratio)).subtract(globalToLocal(new Point(this.width/6, this.width/6*ratio)));
			
			sheet.width = adjustedDimension.x;
			sheet.height = adjustedDimension.y;	
		}
		else {
			sheet.width = width;
			sheet.height = height;
		}
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
	
	private function onSheetMove(e:MoveEvent):void
	{
		
	/**** LETS FIX THIS! ****/
//		var dScale:Number = 0.0;
//		
//	//	trace(childrenExtent.x, childrenExtent.y);
//	//	trace(childrenExtent.width, childrenExtent.height);
//	//	trace(width, height);
//		
//		if(childrenExtent.x < 0)
//			dScale = Math.min(2 * childrenExtent.x / width, dScale);
//		if(childrenExtent.y < 0)
//			dScale = Math.min(2 * childrenExtent.y / height, dScale);
//		if(childrenExtent.x + childrenExtent.width > width)
//			dScale = Math.min(2 * (childrenExtent.x + childrenExtent.width - width) / width, dScale);
//		if(childrenExtent.y + childrenExtent.height > height)
//			dScale = Math.min(2 * (childrenExtent.y + childrenExtent.height - height) / height, dScale);
//		
//		trace("multiplier: " + dScale);
//		
//		setZoom(dScale * zoomX);
	}
	
	public function addSheet(sheet:Sheet):void
	{
		sheet.addFocusInEventListener(onSheetFocusEvent); 
		sheet.addCommitEventListener(onSheetCommitEvent);
		sheet.addCloseEventListener(onSheetClose);
		sheet.addMovedEventListener(onSheetMove);
		addChild(sheet);
	}
	
	public function removeSheet(sheet:Sheet):void
	{
		removeChild(sheet);
		sheet.removeCloseEventListener(onSheetClose);
		sheet.removeCommitEventListener(onSheetCommitEvent);
		sheet.removeFocusInEventListener(onSheetFocusEvent);
		sheet.removeMovedEventListener(onSheetMove);
	}
	
	private var _name:String = setUnnamedWall(File.applicationStorageDirectory);
	private function setUnnamedWall(targetDirectory:File):String {
		var contents:Array = targetDirectory.getDirectoryListing();
		var num:int = 0;
		for (var i:uint = 0; i < contents.length; i++) 
		{
			var name:String = contents[i].name as String;
			var matches:Array = name.match(new RegExp("\bunnamed[0-9]{5}\b/"));
			if(matches == null || matches.length != 1)
				continue;
			
			var n:int = parseInt(name.replace(new RegExp("/\bunnamed([0-9]{5})\b/"), "$1"), 10);
			num = n > num ? n : num;	
		}
		var _file:File = null;
		while(true) {
			num ++;
			var newName:String = "0000" + num;
			newName = "unnamed" + newName.substr(newName.length-5, 5); // "000011" => "00011"
			//TODO get current wall's name
			_file = targetDirectory.resolvePath(newName);
			if(!_file.exists) 
				break;
			
			trace("file(" + newName + ") already exists, skipping");
		}
		return newName;
	}
	
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
	
	public function saveWallAs():void {
		var f:File = File.desktopDirectory;
		f.browseForSave("Save As");
		f.addEventListener(flash.events.Event.SELECT, function(e:flash.events.Event):void {
//			var xml:XML = wallXML; // any errors according to serialization must happen beforehand to opening the file
			//why toXML execute FileStoredWall's toXML?? T.T
			var targetDirectory:File = e.target as File;
//			var fs:XMLFileStream = new XMLFileStream(targetDirectory.resolvePath("index.wall"));
//			fs.setXML(xml);
			var sourceDirectory:File = File.applicationStorageDirectory.resolvePath(name);
			sourceDirectory.copyTo(targetDirectory,true);
		});
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
	
	protected function get wallXML():XML {
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
            if(sheet)
			    sheetsXML.appendChild(sheet.toXML());
		}
		xml.appendChild(sheetsXML);
		return xml;
	}
	public function toXML():XML
	{
		return wallXML;
	}
	

}
}