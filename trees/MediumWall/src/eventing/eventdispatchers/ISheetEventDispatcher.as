package eventing.eventdispatchers
{
import eventing.events.ISheetEvent;
import eventing.events.IFocusEvent;

public interface ISheetEventDispatcher extends IDimensionChangeEventDispatcher, 
	IContentChangeEventDispatcher, IFocusEventDispatcher
{

}
}