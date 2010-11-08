package components.capabilities
{
import components.SpatialObject;
import components.controls.ScrollbarBase;
import components.events.PanEvent;

import flash.events.MouseEvent;

import spark.components.Group;

public class Pannability
{
	private var obj:SpatialObject;
	private var childrenHolder:Group
	
	public function Pannability(target:SpatialObject, childrenHolder:Group)
	{
		obj = target;
		this.childrenHolder = childrenHolder;
	}	
	
	private var horizontalScrollbar:ScrollbarBase = new ScrollbarBase();
	private var verticalScrollbar:ScrollbarBase = new ScrollbarBase();
	
	public function panInit():void
	{
		//obj.addEventListener(MouseEvent.MOUSE_DOWN, panStart);
		obj.addElement(horizontalScrollbar);
		obj.addElement(verticalScrollbar);
		horizontalScrollbar.height = 5;
		verticalScrollbar.width = 5;
	}



}
}