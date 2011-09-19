package eventing.events
{

import eventing.eventdispatchers.IEventDispatcher;
import cream.components.IComponent;

public class FocusEvent extends ComponentEvent
{
	public static const FOCUS_IN:String = "focusIn";
	public static const FOCUS_OUT:String = "focusOut";
	
	public function FocusEvent(dispatcher:IEventDispatcher, type:String)
	{
		super(dispatcher, type);
	}
}
}