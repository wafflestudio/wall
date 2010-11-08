package components  {

import components.capabilities.Pannability;
import components.capabilities.Scalability;

import controllers.ApplicationController;

import flash.events.MouseEvent;
import flash.geom.Matrix;

import mx.events.ResizeEvent;

import spark.components.BorderContainer;
import spark.components.Group;
import spark.effects.Scale;
	
	
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
public class Wall extends SpatialObject
{
	
	public static function create(wallXML:XML):Wall  {
		var new_wall:Wall = new Wall();

		
		for each(var sheetXML:XML in wallXML.children())  {			
			var sheet:Sheet = Sheet.create(sheetXML);
			new_wall.childrenContainer.addElement(sheet);
		}
		
		new_wall.width = wallXML.@width;
		new_wall.height = wallXML.@height;
		
		return new_wall;
	}

	private var pannability:Pannability;
	private var scalability:Scalability;
	
	
	public function Wall()  {
		super();
		this.addElement(childrenContainer);
		
		pannability = new Pannability(this, this.childrenContainer);
		scalability = new Scalability(this, this.childrenContainer);
		
	}
	
	public function toXML():XML  {
		var xml:XML = <wall/>;
		for(var i:int  = 0; i < this.numElements; i++)  {
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
		// add scrollbar
	}
	
	
}
}