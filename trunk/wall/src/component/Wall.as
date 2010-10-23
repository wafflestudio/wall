package component  {

import component.event.SpatialEvent;
import component.utils.IScrollable;
import controller.ApplicationController;
import flash.display.DisplayObject;
import mx.core.UIComponent;
import mx.events.ResizeEvent;
import spark.components.BorderContainer;
import spark.components.Group;
import spark.events.ElementExistenceEvent;
	
	
/** Wall: 벽 컴포넌트
 * 
 * 시트를 담는다 (contain) - sheetadded, sheetdestroyed
 * 
 * 시트를 움직이는 경우 영역의 변화 - 시트의 spatialevent에 반응해서 영역을 변화시키도록 한다.
 *   - 이 작업은 application controller에서 정의한다.
 * 
 * 스크롤한다 (scroll) - scrolling, scrolled
 * 
 * 줌 인/아웃이 된다.(휠, 핀치) zooming zoomed
 * 
 * 몇 개의 벽이 겹쳐진다
 * 
 * 생성되고 보여지고 파괴된다. create destroy  
 * 
 * */

[Event(name="scrolling", type="flash.events.Event")]
[Event(name="scrolled", type="flash.events.Event")]
[Event(name="zooming", type="flash.events.Event")]
[Event(name="zoomed", type="flash.events.Event")]
public class Wall extends BorderContainer implements IScrollable /**, IZoomable **/
{
	
	public static function create(wallXML:XML):Wall  {
		var new_wall:Wall = new Wall();
		new_wall.addElement(new_wall.childrenHolder);
		for each(var sheetXML:XML in wallXML.children())  {			
			var sheet:Sheet = Sheet.create(sheetXML);
			
			new_wall.childrenHolder.addElement(sheet);
		}
		
		new_wall.width = wallXML.@width;
		new_wall.height = wallXML.@height;

		return new_wall;
	}


	include "utils/FPan.as"
	
	public function Wall()  {
		super();
	}
	
	public function toXML():XML  {
		var xml:XML = <wall/>;
		for(var i:int  = 0; i < this.numElements; i++)  {
			var element:Sheet = this.childrenHolder.getElementAt(i) as Sheet;
			if(element)
				xml.appendChild(element.toXML());
		}
		
		xml.@width = width;
		xml.@height = height;
		
		return xml;
	}
	
	public override function initialize():void  {
		super.initialize();
		initScrollEvent();
		this.percentWidth = 100;
		this.percentHeight = 100;
		this.setStyle("borderAlpha", 0x0);
		this.setStyle("backgroundColor", 0xF2F2F2);
		
		ApplicationController.appWindow.addEventListener(ResizeEvent.RESIZE, onContainerResize);
			
	}
	
	private var containerWidth:Number;
	private var containerHeight:Number;
	private var childrenHolder:Group = new Group();
	
	private function get horizontalOverflow():Boolean {
		return (childrenMaxX - childrenMinX) > containerWidth;
	}
	
	private function get verticalOverflow():Boolean  {
		return (childrenMaxY - childrenMinY) > containerHeight;
	}
	
	private function get contentWidth():Number {
		var childrenRange:Number = childrenMaxX - childrenMinX;
		return childrenRange > containerWidth ? childrenRange : containerWidth;
	}
	
	private function get contentHeight():Number { 
		var childrenRange:Number = childrenMaxY - childrenMinY;
		return childrenRange > containerHeight ? childrenRange : containerHeight;  
	}
	
	private function get childrenMaxX():Number {
		var found:Boolean = false;
		var maxx:Number = 0;
		
		for(var i:int  = 0; i < childrenHolder.numElements; i++)  {
			var element:Sheet = childrenHolder.getElementAt(i) as Sheet;
			if(element)  {
				if(!found || maxx < (element.x + element.width))  {
					maxx = (element.x + element.width);
					found = true;
				}
			}
		}
		return maxx;
	}
	
	private function get childrenMinX():Number {
		var found:Boolean = false;
		var minx:Number = 0;
		
		for(var i:int  = 0; i < childrenHolder.numElements; i++)  {
			var element:Sheet = childrenHolder.getElementAt(i) as Sheet;
			if(element)  {				
				if(!found || element.x < minx)  {
					minx = element.x;
					found = true;
				}
			}
			
		}
		
		return minx;
	}
	
	private function get childrenMaxY():Number {
		var found:Boolean = false;
		var maxy:Number = 0;
		
		for(var i:int  = 0; i < childrenHolder.numElements; i++)  {
			var element:Sheet = childrenHolder.getElementAt(i) as Sheet;
			if(element)  {
				if(!found || maxy < (element.y + element.height))  {
					maxy = (element.y + element.height);
					found = true;
				}
			}
			
		}
		
		return maxy;
	}
	
	
	
	private function get childrenMinY():Number {
		var found:Boolean = false;
		var miny:Number = 0;
		
		for(var i:int  = 0; i < childrenHolder.numElements; i++)  {
			var element:Sheet = childrenHolder.getElementAt(i) as Sheet;
			if(element)  {
				if(!found || element.y < miny)  {
					miny = element.y;
					found = true;
				}
			}
			
		}
		
		return miny;
	}
	
	private function onContainerResize(e:ResizeEvent):void  {
		containerWidth = e.target.width;
		containerHeight = e.target.height;
	}
	
	
	private function initScrollEvent():void  {
		/** 드래그 기능 초기화 **/
		panInit();
		
//		this.addEventListener(PanEvent.PAN,
//			function(e:PanEvent):void { 
//				dispatchEvent(new SpatialEvent(SpatialEvent.MOVING,
//					false, false, e.x, e.y)); 
//			} 
//		);
//		
//		this.addEventListener(PanEvent.PAN_END,
//			function(e:PanEvent):void { 
//				dispatchEvent(new SpatialEvent(SpatialEvent.MOVED,
//					false,false, e.x, e.y)); 
//			} 
//		);		
	}
	
	
	protected override function createChildren():void  {
		super.createChildren();
		// add scrollbar
	}
	
	private function panBoundx(x:Number):Number { return x; }
	private function panBoundy(y:Number):Number { return y; }

}
}