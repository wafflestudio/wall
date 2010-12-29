package components  {
	
import components.capabilities.Movability;
import components.events.SpatialEvent;

import flash.display.Graphics;
import flash.events.Event;

import spark.components.BorderContainer;
import spark.components.TextArea;

/** Sheet: 시트 컴포넌트. 
 * 
 * Wall상에 놓이고 컨텐트를 담는다 
 * 
 * 벽 상에서 움직이고, (moving, moved)
 * 사이즈가 조절되고 	(resizing, resized)
 * 컨텐트 줌 인/아웃이 된다  (zooming, zommed)
 * 
 * 시트 자체로 드래그가 되고
 * 리사이즈 컨트롤이 부착되어 있고
 * 줌 컨트롤이 부착되어 있다
 * 
 * 생성과 삭제
 * 
 * */
[Event(name="moving", type="flash.events.Event")]
[Event(name="moved", type="flash.events.Event")]
[Event(name="resizing", type="flash.events.Event")]
[Event(name="resized", type="flash.events.Event")]
[Event(name="zooming", type="flash.events.Event")]
[Event(name="zoomed", type="flash.events.Event")]
public class Sheet extends SpatialObject
{
	
	public static function create(sheetXML:XML):Sheet  {
		var new_sheet:Sheet = new Sheet();
		new_sheet.x = sheetXML.@x;
		new_sheet.y = sheetXML.@y;
		new_sheet.width = sheetXML.@width;
		new_sheet.height = sheetXML.@height;
		
		return new_sheet;
	}

	private var movability:Movability;
	
	
	public function Sheet()  {
		super();
		movability = new Movability(this);
	}
	
	public function toXML():XML  {
		var xml:XML = <sheet/>;
		xml.@x = this.x;
		xml.@y = this.y;
		xml.@width = this.width;
		xml.@height = this.height;
		return xml;
	}
	
	/** initialize()
	 * 
	 * 컴포넌트 초기화
	 * 
	 * initialize sevents
	 *  
	 * 
	 **/
	public override function initialize():void  {
		super.initialize();
	}
	
	/** createChildren:
	 * 
	 * 자식 노드 생성
	 * 
	 * */
	protected override function createChildren():void  {
		super.createChildren();	
	}

	
	
}
}