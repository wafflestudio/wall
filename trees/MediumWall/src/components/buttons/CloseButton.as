package components.buttons
{
import flash.events.MouseEvent;
import flash.events.Event;

public class CloseButton extends Button
{
	public function CloseButton()
	{
		this.height = this.width = 10;
		
	}
	
	override public function initialize():void  {
		super.initialize();
		this.graphics.beginFill(0xff0000);
		this.graphics.drawRect(0,0, 10, 10);
		this.graphics.endFill();
	}
}
}