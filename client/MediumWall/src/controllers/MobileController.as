package controllers
{
	import components.perspectives.IPerspective;
	
	import flash.errors.IOError;
	import flash.filesystem.File;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Application;
	import spark.components.ViewNavigatorApplication;
	
	
	import views.WallView;

	public class MobileController
	{
		private static var configFile:File = File.applicationStorageDirectory.resolvePath( "wallconf.xml" );
		private var config:IFileStoredConfig;
		
		public function MobileController()
		{
			
		}
		
		public function load():void
		{
			config = new MobileConfig();
			
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
		
		public function setup(app:Application):void
		{
			var mobileApp:ViewNavigatorApplication = app as ViewNavigatorApplication;
			
			
//			mobileApp.navigator.pushView(WallView, 
						
		}
	}
}