package components
{
import eventing.events.IClickEvent;
import eventing.events.Event;
import eventing.events.ClickEvent;

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
	
	public function dispatchClickEvent(e:IClickEvent = null):void
	{
		dispatchEvent(new ClickEvent(this));	
	}
}
}