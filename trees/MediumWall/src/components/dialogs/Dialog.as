package components.dialogs
{
import components.Component;
import spark.components.TitleWindow;
import components.popups.Popup;
import mx.events.CloseEvent;

public class Dialog extends Popup
{
	protected var tw:TitleWindow;
	
	public function Dialog()
	{
		tw = new TitleWindow();
		visualElement = tw;
		visualElementContainer = tw;
		
		tw.alpha = 0.8;
		tw.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void { close(); });
	}
	
	public function set title(text:String):void
	{
		tw.title = text;	
	}
	
	public function close():void
	{
		hide();	
	}
}
}