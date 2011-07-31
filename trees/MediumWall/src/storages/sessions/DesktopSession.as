package storages.sessions
{
	import components.perspectives.TabbedPerspective;

	public class DesktopSession extends Session
	{
		public function DesktopSession()
		{
			super();
			_perspective = new TabbedPerspective();
		
			_perspective.addCommitEventListener(function():void
			{
				dispatchCommitEvent();
			});
		}
	}
}