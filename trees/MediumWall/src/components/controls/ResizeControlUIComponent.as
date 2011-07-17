package components.controls
{
import mx.core.UIComponent;
import flash.events.MouseEvent;
import mx.core.IVisualElement;

public class ResizeControlUIComponent extends UIComponent
{
	public function ResizeControlUIComponent()
	{
		super();
		
		this.includeInLayout = false;	
		addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
		{
			
		});
	}
	
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void  {
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		graphics.clear();
		graphics.lineStyle(3,0);

		graphics.drawRoundRect(0,0, unscaledWidth, unscaledHeight, 5 , 5);	
		
		
	}

//	{
//		super.initialize();
//		this.graphics.beginFill(0x00ff00);
//		this.graphics.drawRect(0,0, 100, 100);
//		this.graphics.endFill();
//	}
}
}