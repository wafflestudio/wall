package com.wafflestudio.wall.components.elements  {

import com.wafflestudio.wall.capabilities.Pannability;
import com.wafflestudio.wall.capabilities.Scalability;
import com.wafflestudio.wall.events.ChildrenEvent;
import com.wafflestudio.wall.events.SpatialEvent;
import com.wafflestudio.wall.controllers.MainController;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import mx.controls.Alert;
import mx.core.IVisualElement;
import mx.events.CloseEvent;
import mx.events.ResizeEvent;
import spark.components.BorderContainer;
import spark.components.Group;
import spark.effects.Scale;
import com.wafflestudio.wall.utils.history.History;
import com.wafflestudio.wall.utils.history.Action;


/** Wall: 벽 컴포넌트
 *   
 * 
 * */
[Event(name="scrolling", type="flash.events.Event")]
[Event(name="scrolled", type="flash.events.Event")]
[Event(name="zooming", type="flash.events.Event")]
[Event(name="zoomed", type="flash.events.Event")]
public class Wall extends WallComponent
{
	public static function create(wallXML:XML):Wall  {
		var newWall:Wall = new Wall();
		newWall.init(wallXML);
		return newWall;
	}
	
	protected function init(wallXML:XML):void  {
		
		for each(var sheetXML:XML in wallXML.children())  {			
			addSheet(sheetXML);
		}
		
		panX = wallXML.@panX;
		panY = wallXML.@panY;
		zoomX = zoomY = 
		String(wallXML.@scale).length ? wallXML.@scale : 1.0;
	}
	
	private var pannability:Pannability;
	private var scalability:Scalability;
	private var history:History;

	
	public function Wall()  {
		super();
		
		pannability = new Pannability(this);
		scalability = new Scalability(this);
		history = new History();	
		//			var root:NativeMenu = new NativeMenu();
		//			var copyMenuItem:NativeMenuItem = root.addItem(new NativeMenuItem("copy"));
		//			copyMenuItem.addEventListener(Event.SELECT, function(e:Event):void { Alert.show('');});
		//			var pasteMenuItem:NativeMenuItem = root.addItem(new NativeMenuItem("paste"));
		//			pasteMenuItem.addEventListener(Event.SELECT, function(e:Event):void { Alert.show('');});
		//			
		//			this.contextMenu = root;
		this.addEventListener(Event.PASTE, onPaste);
		this.addEventListener(ChildrenEvent.DIMENSION_CHANGE, function(e:ChildrenEvent):void
			{
				
			});
	}
	
	
	public function addNewBlankSheet():void  {
		var stageCenter:Point = new Point(this.stage.stageWidth/2, this.stage.stageHeight/2);
		trace(stageCenter);
		var center:Point = this.globalToComponentAxis(this.stage.localToGlobal(stageCenter));
		
		var sheetXML:XML = <sheet x={center.x-150} y={center.y-200} width='300' height='400' type='text'/>;
		this.addSheet(sheetXML);	
	}
	
	
	public function addSheet(sheetXML:XML):void
	{
		var sheet:Sheet = Sheet.create(sheetXML);
		addComponent(sheet);
		
		sheet.addEventListener(SpatialEvent.MOVING, 
			function(e:Event):void { 
				dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE)); 
			}
		);
					
		var self:Wall = this;
		
		// Move action
		sheet.addEventListener(SpatialEvent.MOVED, 
			function(e:SpatialEvent):void { 
				dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE)); 
				self.history.writeForward(new Action("move", [sheet, e.x, e.y]));
			}
		);
		
		// Close action
		sheet.addEventListener(ChildrenEvent.CLOSE_ACTION, 
			function(e:ChildrenEvent):void  {
				Alert.show("Are you sure you want to remove this sheet?", "Remove sheet", Alert.OK | Alert.CANCEL, null,
					function closeHandler(ce:CloseEvent):void  {
						if(ce.detail == Alert.OK)  {
							this.removeComponent(sheet);
							dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE));
						}
					}
				);
			}
		);
		
		dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE));
	}
	
	
	public function toXML():XML  {
		var xml:XML = <wall/>;
		for(var i:int  = 0; i < this.numComponents; i++)  {
			var element:Sheet = this.getComponentAt(i) as Sheet;
			if(element)
				xml.appendChild(element.toXML());
		}
	
		xml.@panX = panX;
		xml.@panY = panY;
		xml.@scale = zoomX;
		
		return xml;
	}
	
	
	public static function get defaultValue():XML  {
		// TODO: implement
		var wallXML:XML = 
			<wall>
				<sheet x='10' y='10' width='300' height='400' type='text'/>
				<sheet x='100' y='15' width='400' height='600' type='text'/>
			</wall>
		return wallXML;
	}
	
	
	public override function initialize():void  {
		super.initialize();
		setDefaultStyle();
	}
	
	
	protected override function createChildren():void  {
		super.createChildren();
	}
	
	
	private function setDefaultStyle():void  {
		this.percentWidth = 100;
		this.percentHeight = 100;
		
		this.setStyle("borderAlpha", 0x0);
		this.setStyle("backgroundColor", 0xF2F2F2);
	}
	

	private function onPaste(e:Event):void  {
		// TODO: implement
		if(e.target == e.currentTarget)
			Alert.show( e.target.toString());
			
	}
	
}
}