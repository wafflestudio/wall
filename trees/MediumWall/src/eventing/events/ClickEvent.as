package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;


public class ClickEvent extends MouseEvent implements IClickEvent
{	
	public static const CLICK:String = "click";
	
	public function ClickEvent(dispatcher:IEventDispatcher)
	{
		super(dispatcher, CLICK, 0, 0, 0, 0);
	}
}
}