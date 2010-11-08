package components.capabilities
{
import components.SpatialObject;
import components.controls.ScrollbarBase;
import components.events.PanEvent;

import flash.events.MouseEvent;

import spark.components.Group;

public class Pannability
{
	private var target:SpatialObject;
	private var childrenHolder:Group
	
	public function Pannability(target:SpatialObject, childrenContainer:Group)
	{
		this.target = target;
		this.childrenHolder = childrenHolder;
	}	
	
	private function panInit():void
	{
		target.addEventListener(MouseEvent.MOUSE_DOWN, panStart);
	}
	
	private function panStart(e:MouseEvent):void  {
		target.stage.addEventListener(MouseEvent.MOUSE_MOVE, pan);
		target.stage.addEventListener(MouseEvent.MOUSE_UP, panEnd);
	}
	
	private function pan(e:MouseEvent):void  {
		
	}
	
	private function panEnd(e:MouseEvent):void  {
		
	}



}
}