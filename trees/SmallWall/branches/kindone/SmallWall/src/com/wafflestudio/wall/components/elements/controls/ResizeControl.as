package com.wafflestudio.wall.components.elements.controls
{
import mx.core.UIComponent;
import com.wafflestudio.wall.components.elements.WallComponent;

public class ResizeControl extends UIComponent
{
	public function ResizeControl(target:WallComponent)
	{
		this.includeInLayout = false;	
	}
	
	override public function initialize():void
	{
		super.initialize();
		this.graphics.beginFill(0x00ff00);
		this.graphics.drawRect(0,0, 10, 10);
		this.graphics.endFill();
	}
}
}