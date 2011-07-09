package components.dialogs
{
import components.IComponent;
import components.popups.IPopup;

public interface IDialog extends IPopup
{
	function set title(text:String):void;
	function close():void;
}
}