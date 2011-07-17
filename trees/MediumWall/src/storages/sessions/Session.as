package storages.sessions
{
import components.perspectives.IPerspective;
import storages.IXMLizable;
import components.perspectives.Perspective;
import components.perspectives.MultipleWallPerspective;
import components.perspectives.TabbedPerspective;
import eventing.eventdispatchers.EventDispatcher;
import eventing.events.CommitEvent;

public class Session extends EventDispatcher implements ISession
{
	private var _perspective:IPerspective;
	
	public function Session()
	{
		_perspective = new TabbedPerspective();
		_perspective.addCommitEventListener(function():void
		{
			dispatchCommitEvent();
		});
	}
	
	public function get perspective():IPerspective
	{
		return _perspective;
	}
	
	public function addCommitEventListener(listener:Function):void
	{
		addEventListener(CommitEvent.COMMIT, listener);	
	}
	
	public function removeCommitEventListener(listener:Function):void
	{
		removeEventListener(CommitEvent.COMMIT, listener);	
	}
	
	protected function dispatchCommitEvent():void
	{
		dispatchEvent(new CommitEvent(this));
	}
	
	
	/**
	 * <session>
	 * 	<perspective>
	 * 		// perspective
	 * 	</perspective>
	 * </session>
	 */
	public function fromXML(xml:XML):IXMLizable
	{
		return perspective.fromXML(xml.perspective[0]);	
	}
	
	public function toXML():XML
	{
		var xml:XML = <session/>;
		xml.appendChild(perspective.toXML());
		return xml;
	}
	
	public static function get defaultXML():XML
	{
		var session:Session = new Session();
		return session.toXML();
	}
	
	public function get defaultXML():XML
	{
		return Session.defaultXML;
	}
	
	
}
}