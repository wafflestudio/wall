package storages.configs
{
import storages.IXMLizable;
import storages.sessions.ISession;

public interface IConfig extends IXMLizable
{
	function get session():ISession;
}
}