package controllers
{
import history.History;
import spark.components.WindowedApplication;
import flash.filesystem.File;
import mx.events.CloseEvent;
import components.elements.events.FormEvent;
import mx.managers.PopUpManager;
import components.dialogs.SelectWallDialog;
import mx.core.IFlexDisplayObject;
import flash.filesystem.FileStream;
import flash.filesystem.FileMode;
import flash.errors.IOError;
import flash.errors.EOFError;
import components.elements.Wall;
import components.views.MainView;

public class WallController
{
	public var view:MainView;
	public var theWall:Wall;
	// configurations
	private var wallPath:File;
	
	public function WallController()  {	
		loadConfig();
		init();
	}
	
	private function init():void  {
		loadWall(wallPath);
	}
	
	private function loadConfig(configFileName:String = "wallconf.xml"):void  {
	
		
		try {
			var file:File = File.applicationStorageDirectory.resolvePath( configFileName );
			var fileStream:FileStream = new FileStream();
			var configXML:XML;
			
			
			fileStream.open( file, FileMode.READ );
			var fileContent:String = fileStream.readUTFBytes(fileStream.bytesAvailable)
			if(fileContent)
				configXML = new XML(fileContent);
			
		}
		catch(e:IOError)  {
			trace('IOError:' + e.name + ":" + e.message);
		}
		catch(e:EOFError)  {
			trace('EOFError' + e.name + ":" + e.message);
		}
		
		// form default config
		if(configXML == null)
			configXML = defaultConfig;
		
		wallPath = File.userDirectory.resolvePath(configXML.wallPath[0].@value);
		
	}
	
	public function saveConfig(configFileName:String = "wallconf.xml"):void  {
		var file:File = File.applicationStorageDirectory.resolvePath( configFileName );
		var file_stream:FileStream = new FileStream();
		
		file_stream.open( file, FileMode.WRITE );
		file_stream.writeUTFBytes( currentConfig );
		trace('saved at ' + file.nativePath);
	}
	
	
	private function get defaultConfig():XML  {
		var f:File = File.userDirectory.resolvePath( "index.wall" );
		
		var wallXML:XML = 	
			<infiniteWall>
				<wallPath value={f.nativePath}/>
			</infiniteWall>
		return wallXML;
	}
	
	private function get currentConfig():XML  {
		var wallXML:XML = 	
			<infiniteWall>
				<wallPath value={wallPath.nativePath}/>
			</infiniteWall>
		return wallXML;
	}
	
	public function loadWall(wallFile:File):void  {
		var file:File = wallFile;
		
		var fileStream:FileStream = new FileStream();
		var wallXML:XML;
		
		try {
			fileStream.open( file, FileMode.READ );
			var file_content:String = fileStream.readUTFBytes(fileStream.bytesAvailable)
			if(file_content)
				wallXML = new XML(file_content);
		}
		catch(e:IOError)  {
			trace('unable to find file');
		}
		catch(e:EOFError)  {
			trace('bad reading of stream');
		}
		
		if(wallXML == null)
			wallXML = Wall.defaultValue;
		
		view = new MainView();
		
		theWall = Wall.create(wallXML);
		view.addElement( theWall );
			
	}
	
	public function saveCurrentWall():void  {
		var file:File = wallPath;
		var fileStream:FileStream = new FileStream();
		
		fileStream.open( file, FileMode.WRITE );
		fileStream.writeUTFBytes( currentWallXML );
		trace('saved at ' + file.nativePath);
	}
	
	private function get currentWallXML():XML  {
		return theWall.toXML();
	}
	
	public function addNewBlankSheet():void
	{
		theWall.addNewBlankSheet();
	}
}
}