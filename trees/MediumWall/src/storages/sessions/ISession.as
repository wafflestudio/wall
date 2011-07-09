package storages.sessions
{
import components.perspectives.IPerspective;
import storages.IXMLizable;
import eventing.eventdispatchers.ICommitEventDispatcher;

public interface ISession extends IXMLizable, ICommitEventDispatcher
{	
	function get perspective():IPerspective;
}
}