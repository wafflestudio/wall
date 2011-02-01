package components  {

	import behaviors.capabilities.Pannability;
	import behaviors.capabilities.Scalability;
	import behaviors.events.ChildrenEvent;
	import behaviors.events.SpatialEvent;
	
	import controllers.ApplicationController;
	
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
	
	
	/** Wall: 벽 컴포넌트
	 *   
	 * 
	 * */
	[Event(name="scrolling", type="flash.events.Event")]
	[Event(name="scrolled", type="flash.events.Event")]
	[Event(name="zooming", type="flash.events.Event")]
	[Event(name="zoomed", type="flash.events.Event")]
	public class Wall extends SpatialObject
	{
		
		public static function create(wallXML:XML):Wall  {
			var new_wall:Wall = new Wall();
	
			for each(var sheetXML:XML in wallXML.children())  {			
				new_wall.addSheet(sheetXML);
			}
			
			new_wall.width = wallXML.@width;
			new_wall.height = wallXML.@height;
			new_wall.childrenContainer.x = wallXML.@panX;
			new_wall.childrenContainer.y = wallXML.@panY;
			new_wall.childrenContainer.scaleX = new_wall.childrenContainer.scaleY = 
				String(wallXML.@scale).length ? wallXML.@scale : 1.0;
			
			return new_wall;
		}
		
		public function addBlankSheet():void  {
			var stage_center:Point = new Point(this.stage.stageWidth/2, this.stage.stageHeight/2);
			trace(stage_center);
			var center:Point = this.childrenContainer.globalToLocal(this.stage.localToGlobal(stage_center));
		
			var sheetXML:XML = <sheet x={center.x-150} y={center.y-200} width='300' height='400' type='text'/>;
			this.addSheet(sheetXML);	
		}
	
		private var pannability:Pannability;
		private var scalability:Scalability;
		
		
		public function Wall()  {
			super();
			
			pannability = new Pannability(this, this.childrenContainer);
			scalability = new Scalability(this, this.childrenContainer);
			
//			var root:NativeMenu = new NativeMenu();
//			var copyMenuItem:NativeMenuItem = root.addItem(new NativeMenuItem("copy"));
//			copyMenuItem.addEventListener(Event.SELECT, function(e:Event):void { Alert.show('');});
//			var pasteMenuItem:NativeMenuItem = root.addItem(new NativeMenuItem("paste"));
//			pasteMenuItem.addEventListener(Event.SELECT, function(e:Event):void { Alert.show('');});
//			
//			this.contextMenu = root;
			this.addEventListener(Event.PASTE, onPaste);
		}
		
		public function addSheet(sheetXML:XML):void
		{
			var sheet:Sheet = Sheet.create(sheetXML);
			childrenContainer.addElement(sheet);
			sheet.addEventListener(SpatialEvent.MOVING, 
				function(e:Event):void { 
					dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE)); 
				}
			);
			sheet.addEventListener(SpatialEvent.MOVED, 
				function(e:Event):void { 
					dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE)); 
				}
			);
			
			// Close action
			sheet.addEventListener(ChildrenEvent.CLOSE_ACTION, 
				function(e:ChildrenEvent):void  {
					Alert.show("Are you sure you want to remove this sheet?", "Remove sheet", Alert.OK | Alert.CANCEL, null,
						function closeHandler(ce:CloseEvent):void  {
							if(ce.detail == Alert.OK)  {
								childrenContainer.removeElement(sheet);
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
			for(var i:int  = 0; i < this.childrenContainer.numElements; i++)  {
				var element:Sheet = this.childrenContainer.getElementAt(i) as Sheet;
				if(element)
					xml.appendChild(element.toXML());
			}
			
			xml.@width = width;
			xml.@height = height;
			xml.@panX = childrenContainer.x;
			xml.@panY = childrenContainer.y;
			xml.@scale = childrenContainer.scaleX;
			
			return xml;
		}
		
		public override function initialize():void  {
			super.initialize();
			setDefaultStyle();
		}
		
		
		private function setDefaultStyle():void  {
			this.percentWidth = 100;
			this.percentHeight = 100;
			this.setStyle("borderAlpha", 0x0);
			this.setStyle("backgroundColor", 0xF2F2F2);
		}
		
	
		protected override function createChildren():void  {
			super.createChildren();
		}
		
		private function onPaste(e:Event):void  {
			if(e.target == e.currentTarget)
//				Alert.show( e.target.toString());
				;
		}
		
	}
}