package controllers
{
	import components.perspectives.IMultipleWallPerspective;
	
	import flash.errors.IOError;
	import flash.filesystem.File;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Application;
	
	import storages.configs.Config;
	import storages.configs.DesktopConfig;
	import storages.configs.FileStoredConfig;
	import storages.configs.IFileStoredConfig;

	public class DesktopController implements IDesktopController
	{
	
		private static var configFile:File = File.applicationStorageDirectory.resolvePath( "wallconf.xml" );
		private var config:IFileStoredConfig;
		
		public function DesktopController()
		{
		}
		
		public function load():void
		{
			config = new DesktopConfig();
			
			try  {
				config.load();
			}
			catch(e:IOError)  {
				var defaultConf:XML = Config.defaultXML;
				trace("failed to load config file, loading default: " + defaultConf);
				config.fromXML(defaultConf);
			}
		}
		
		public function save():void
		{
			config.saveAs();
		}
		
		public function setup(app:IVisualElementContainer):void
		{
			var perspective:IMultipleWallPerspective = config.session.perspective as IMultipleWallPerspective;
			perspective.addToApplication(app);
			
		}
	}
}