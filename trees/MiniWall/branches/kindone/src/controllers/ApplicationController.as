package controllers
{
import components.Wall;
import components.dialogs.SelectWallDialog;

import flash.errors.EOFError;
import flash.errors.IOError;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import mx.core.IFlexDisplayObject;
import mx.managers.PopUpManager;

import spark.components.TitleWindow;
import spark.components.WindowedApplication;
import mx.events.CloseEvent;
import flash.events.Event;
import mx.events.FlexEvent;
import behaviors.events.FormEvent;

public class ApplicationController
{
	private var appWindow:WindowedApplication;
	private var theWall:Wall;
	// configurations
	private var wallPath:File;
	
	public function ApplicationController(app:WindowedApplication)  {	
		this.appWindow = app;
		loadConfig();
		loadWall(wallPath);
		
	}
	
	public function newSheet():void
	{
		theWall.addBlankSheet();
	}
	
	private function loadConfig():void  {
		var file:File = File.applicationStorageDirectory.resolvePath( "wallconf.xml" );
		var fileStream:FileStream = new FileStream();
		var confXML:XML;
		
		try {
			fileStream.open( file, FileMode.READ );
			var fileContent:String = fileStream.readUTFBytes(fileStream.bytesAvailable)
			if(fileContent)
				confXML = new XML(fileContent);
		}
		catch(e:IOError)  {
			trace('unable to find file');
		}
		catch(e:EOFError)  {
			trace('bad reading of stream');
		}
		
		// form default config
		if(confXML == null)
			confXML = defaultConfig;
		
		wallPath = File.userDirectory.resolvePath(confXML.wallPath[0].@value);
	}
	
	public function saveConfig():void  {
		var file:File = File.applicationStorageDirectory.resolvePath( "wallconf.xml" );
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
	
	
	public function changeCurrentWall():void  {
		var win:SelectWallDialog = new SelectWallDialog();
		
		win.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void  {
			PopUpManager.removePopUp(win);
			saveConfig();
		});
		win.addEventListener(FormEvent.CHANGE, function(e:FormEvent):void  {
			wallPath = File.userDirectory.resolvePath(String(e.xml.selectedPath[0].@value) + "/index.wall");
		});		
		PopUpManager.addPopUp(win as IFlexDisplayObject, appWindow);
		PopUpManager.centerPopUp(win);
	}

	public function loadWall(wall:File):void  {
		var file:File = wall;
		
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
		
		theWall = Wall.create(wallXML);	
		appWindow.addElement(theWall);
	}
	
	public function saveWall():void  {
		var file:File = wallPath;
		var fileStream:FileStream = new FileStream();
		
		fileStream.open( file, FileMode.WRITE );
		fileStream.writeUTFBytes( currentWall );
		trace('saved at ' + file.nativePath);
	}
	
	private function get currentWall():XML  {
		return theWall.toXML();
	}

}
}