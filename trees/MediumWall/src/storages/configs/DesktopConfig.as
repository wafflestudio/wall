package storages.configs
{
	import storages.sessions.DesktopSession;

	public class DesktopConfig extends FileStoredConfig implements IMobileConfig
	{
		public function DesktopConfig()
		{
			super();
			_session = new DesktopSession();
			_session.addCommitEventListener( function():void
			{
				saveAs();
			});
		}
	}
}