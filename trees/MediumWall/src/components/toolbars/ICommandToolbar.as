package components.toolbars
{

import eventing.eventdispatchers.IClickEventDispatcher;
import eventing.eventdispatchers.IMouseEventDispatcher;

public interface ICommandToolbar extends IToolbar
{
	function get openWallButton():IClickEventDispatcher;
	function get newWallButton():IClickEventDispatcher;
	function get newSheetButton():IClickEventDispatcher;
	function get newImageButton():IClickEventDispatcher;
	
}
}