package components
{
import eventing.eventdispatchers.IEventDispatcher;
import eventing.eventdispatchers.ICompositeEventDispatcher;

public interface IComposite extends ICompositeEventDispatcher
{
	function addChild(child:IComposite):IComposite;
	function removeChild(child:IComposite):IComposite;
}
}