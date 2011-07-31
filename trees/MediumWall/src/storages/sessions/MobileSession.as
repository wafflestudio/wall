package storages.sessions
{
	import components.perspectives.MobilePerspective;

	public class MobileSession extends Session
	{
		public function MobileSession()
		{
			super();
//			_perspective = new TabbedPerspective();
			_perspective = new MobilePerspective();
			_perspective.addCommitEventListener(function():void
			{
				dispatchCommitEvent();
			});
		}
	}
}