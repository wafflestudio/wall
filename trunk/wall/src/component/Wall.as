package component  {

import component.utils.IScrollable;

import model.SheetData;

import mx.events.ResizeEvent;

import spark.components.BorderContainer;
	
	
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
public class Wall extends BorderContainer implements IScrollable/**, IZoomable **/
{
	
	public static function create(wallData:model.WallData):Wall  {
		var new_wall:Wall = new Wall();
		
		for each(var sheetData:model.SheetData in wallData.sheets)  {
			var sheet:Sheet = Sheet.create(sheetData);
			new_wall.addElement(sheet);
		}
		
		new_wall.width = wallData.width;
		new_wall.height = wallData.height;

		return new_wall;
	}
	
	

	public function Wall()  {
		super();
	}
	
	public override function initialize():void  {
		super.initialize();
		this.setStyle("borderColor", 0x0);
		this.setStyle("backgroundColor", 0xF2F2F2);
		
		contentWidthHolder = width;
		contentHeightHolder = height;
	}
	
	public function set contentWidth(value:Number):void	 {
		if(contentWidthHolder == value)
			return;
		contentWidthHolder = value;	
	}
	
	public function set contentheight(value:Number):void  {
		if(contentHeightHolder == value)
			return ;
		contentHeightHolder = value;
		// display scrollbar
		// reposiion scrollbar
		// height(value);	
	}
	
	protected override function createChildren():void  {
		super.createChildren();
		// add scrollbar
	}
	
	private var contentWidthHolder : Number;
	private var contentHeightHolder : Number;
	
}
}