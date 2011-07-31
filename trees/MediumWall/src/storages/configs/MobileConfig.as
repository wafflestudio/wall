package storages.configs
{
	import storages.sessions.MobileSession;

	public class MobileConfig extends FileStoredConfig implements IMobileConfig
	{
		public function MobileConfig()
		{
			_session = new MobileSession();
			_session.addCommitEventListener( function():void
			{
				saveAs();
			});
		}
	}
}