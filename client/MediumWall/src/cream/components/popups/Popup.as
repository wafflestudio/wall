package cream.components.popups
{
import cream.components.Component;
import mx.managers.PopUpManager;
import mx.core.FlexGlobals;
import flash.display.DisplayObject;
import mx.core.IFlexDisplayObject;

public class Popup extends Component
{
	public function Popup()
	{
		super();
	}
	
	public function show():void
	{
		PopUpManager.addPopUp(visualElement as IFlexDisplayObject, FlexGlobals.topLevelApplication as DisplayObject, true);
		PopUpManager.centerPopUp(visualElement as IFlexDisplayObject);
	}
	
	public function hide():void
	{
		PopUpManager.removePopUp(visualElement as IFlexDisplayObject);
	}
}
}