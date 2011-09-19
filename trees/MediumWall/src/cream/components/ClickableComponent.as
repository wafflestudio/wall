package cream.components
{
import cream.eventing.events.Event;
import cream.eventing.events.ClickEvent;

public class ClickableComponent extends Component implements IClickableComponent
{
	public function ClickableComponent()
	{
		super();
	}
	
	public function addClickEventListener(listener:Function):void
	{
		addEventListener(ClickEvent.CLICK, listener);
	}
	
	public function removeClickEventListener(listener:Function):void
	{
		removeEventListener(ClickEvent.CLICK, listener);
	}
	
	public function dispatchClickEvent(e:ClickEvent = null):void
	{
		dispatchEvent(new ClickEvent(this));	
	}
}
}