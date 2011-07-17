package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;


public class ClickEvent extends MouseEvent
{	
	public static const CLICK:String = "click";
	
	public function ClickEvent(dispatcher:IEventDispatcher)
	{
		super(dispatcher, CLICK, 0, 0, 0, 0);
	}
}
}