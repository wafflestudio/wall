package components  {

	import components.capabilities.Pannability;
	import components.capabilities.Scalability;
	import components.controls.IScrollable;
	import components.events.ChildrenEvent;
	import components.events.SpatialEvent;
	import controllers.ApplicationController;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import mx.events.ResizeEvent;
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.effects.Scale;
	import mx.core.IVisualElement;
	
	
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
				var sheet:Sheet = Sheet.create(sheetXML);
				new_wall.childrenContainer.addElement(sheet);
				sheet.addEventListener(SpatialEvent.MOVING, 
					function(e:Event):void { 
						new_wall.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE)); 
					}
				);
				sheet.addEventListener(SpatialEvent.MOVED, 
					function(e:Event):void { 
						new_wall.dispatchEvent(new ChildrenEvent(ChildrenEvent.DIMENSION_CHANGE)); 
					}
				);
			}
			
			new_wall.width = wallXML.@width;
			new_wall.height = wallXML.@height;
			
			return new_wall;
		}
	
		private var pannability:Pannability;
		private var scalability:Scalability;
		
		
		public function Wall()  {
			super();
			
			//pannability = new Pannability(this, this.childrenContainer);
			scalability = new Scalability(this, this.childrenContainer);
			
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
		
		
	}
}