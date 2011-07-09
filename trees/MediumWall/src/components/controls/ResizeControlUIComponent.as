package components.controls
{
import mx.core.UIComponent;

public class ResizeControlUIComponent extends UIComponent
{
	public function ResizeControlUIComponent()
	{
		super();
		this.includeInLayout = false;	
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void  {
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		this.graphics.clear();
		this.graphics.lineStyle(3,0);

		this.graphics.drawRoundRect(0,0, 100, 100, 5 , 5);	

	}

//	{
//		super.initialize();
//		this.graphics.beginFill(0x00ff00);
//		this.graphics.drawRect(0,0, 100, 100);
//		this.graphics.endFill();
//	}
}
}