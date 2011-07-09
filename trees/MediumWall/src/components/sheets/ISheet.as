package components.sheets
{
import storages.IXMLizable;
import eventing.eventdispatchers.ISheetEventDispatcher;
import eventing.eventdispatchers.ICommitEventDispatcher;
import components.ICommitableComponent;
import components.IFlexibleComponent;

public interface ISheet extends IFlexibleComponent, IXMLizable,ISheetEventDispatcher,ICommitableComponent
{
	
}
}