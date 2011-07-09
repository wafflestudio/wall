package components.toolbars
{

import eventing.eventdispatchers.IMouseEventDispatcher;
import eventing.eventdispatchers.IClickEventDispatcher;

public interface ICommandToolbar extends IToolbar
{
	function get openWallButton():IClickEventDispatcher;
	function get newWallButton():IClickEventDispatcher;
	function get newSheetButton():IClickEventDispatcher;
	
}
}