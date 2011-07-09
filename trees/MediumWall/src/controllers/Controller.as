package controllers
{
import flash.filesystem.File;
import storages.configs.IFileStoredConfig;
import storages.configs.FileStoredConfig;
import storages.sessions.ISession;
import components.perspectives.IPerspective;
import spark.components.Application;
import components.perspectives.TabbedPerspective;
import storages.sessions.Session;
import flash.errors.IOError;
import storages.configs.Config;
import components.perspectives.IMultipleWallPerspective;
import eventing.events.IEvent;
import mx.controls.Alert;
import components.walls.Wall;

public class Controller implements IController
{
	private static var configFile:File = File.applicationStorageDirectory.resolvePath( "wallconf.xml" );
	private var config:IFileStoredConfig;
	
	public function load():void
	{
		config = new FileStoredConfig();
		
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
		config.save();
	}
	
	public function setup(app:Application):void
	{
		var perspective:IMultipleWallPerspective = config.session.perspective as IMultipleWallPerspective;
		perspective.addToApplication(app);
		
	}
}
}