package component  {

import component.control.Scrollbar;
import component.event.SpatialEvent;
import component.utils.IScrollable;

import controller.ApplicationController;

import flash.display.DisplayObject;
import flash.geom.Matrix;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.core.UIComponent;
import mx.events.ResizeEvent;
import mx.utils.ObjectUtil;

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
public class Wall extends BorderContainer implements IScrollable 
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
		initPanEvent();
		this.percentWidth = 100;
		this.percentHeight = 100;
		this.setStyle("borderAlpha", 0x0);
		this.setStyle("backgroundColor", 0xF2F2F2);
		
		ApplicationController.appWindow.addEventListener(ResizeEvent.RESIZE, onContainerResize);
		var self:Wall = this;
		self.addEventListener(MouseEvent.MOUSE_WHEEL,function(e:MouseEvent):void {
			var multiplier:Number = Math.pow(1.1, e.delta);
//			self.childrenHolder.scaleX *= multiplier;
//			self.childrenHolder.scaleY *= multiplier;
//			self.childrenHolder.x = (self.childrenHolder.x- containerWidth/2) * multiplier + containerWidth/2;
//			self.childrenHolder.y = (self.childrenHolder.y- containerHeight/2) * multiplier + containerHeight/2;;
			var oldmatrix:Matrix = self.childrenHolder.transform.matrix;
			var matrix:Matrix = new Matrix(oldmatrix.a, oldmatrix.b, oldmatrix.c, oldmatrix.d, oldmatrix.tx, oldmatrix.ty);
			matrix.translate(-containerWidth/2, -containerHeight/2);
			matrix.scale(multiplier, multiplier);
			matrix.translate(containerWidth/2, containerHeight/2);
			self.childrenHolder.transform.matrix = matrix;
			
			trace(self.childrenHolder.x);
			
		});
	}
	
	private var containerWidth:Number;
	private var containerHeight:Number;
	private var childrenHolder:Group = new Group();
	
	private function get horizontalOverflow():Boolean {
		return (childrenMaxX - childrenMinX)*childrenHolder.scaleX > containerWidth;
	}
	
	private function get verticalOverflow():Boolean  {
		return (childrenMaxY - childrenMinY)*childrenHolder.scaleY > containerHeight;
	}
	
	private function get contentWidth():Number {
		var childrenRange:Number = (childrenMaxX - childrenMinX)*childrenHolder.scaleX;
		return childrenRange > containerWidth ? childrenRange : containerWidth;
	}
	
	private function get contentHeight():Number { 
		var childrenRange:Number = (childrenMaxY - childrenMinY)*childrenHolder.scaleY;
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
	
	
	private function initPanEvent():void  {
		/** 드래그 기능 초기화 **/
		panInit();	
		//this.addEventListener(PanEvent.PAN, updateScrollbarsByPan);
		//var watcherSetter:ChangeWatcher = BindingUtils.bindSetter(updateMyString, this, "");

	}
	
	
	protected override function createChildren():void  {
		super.createChildren();
		// add scrollbar
	}
	
	
}
}