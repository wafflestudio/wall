package components.controls
{
import mx.core.UIComponent;
import components.Component;

public class ResizeControl extends UIComponent
{
	public function ResizeControl(target:Component)
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