package storages.configs
{
import storages.IXMLizable;
import storages.sessions.ISession;
import storages.sessions.Session;

public class Config implements IConfig
{
	private var _session:ISession = new Session();;
	
	public function get session():ISession
	{
		return _session;
	}
	
	
	public function Config()
	{
		
	}
	
	/**
	 * <config>
	 * 	<session>
	 * 		//session 
	 * 	</session>
	 * </config>
	*/
	public function fromXML(configXML:XML):IXMLizable
	{
		_session.fromXML(configXML.session[0]);
		// TODO: other configuration values;
		
		return this;	
	}
	
	public function toXML():XML
	{
		var xml:XML = <config/>;
		
		// TODO: other configuration values;
		
		xml.appendChild(_session.toXML());	
		
		return xml;
	}
	
	public static function get defaultXML():XML
	{
		var xml:XML = <config/>;
		xml.appendChild(Session.defaultXML);
		
		// TODO: other configuration values;
		
		return xml;
	}
	
	
}
}