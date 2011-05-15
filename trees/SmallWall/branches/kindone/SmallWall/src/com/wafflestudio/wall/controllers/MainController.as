package com.wafflestudio.wall.controllers
{
import com.wafflestudio.wall.utils.history.History;
import spark.components.WindowedApplication;
import flash.filesystem.File;
import mx.events.CloseEvent;
import com.wafflestudio.wall.components.elements.events.FormEvent;
import mx.managers.PopUpManager;
import com.wafflestudio.wall.components.dialogs.SelectWallDialog;
import mx.core.IFlexDisplayObject;
import flash.filesystem.FileStream;
import flash.filesystem.FileMode;
import flash.errors.IOError;
import flash.errors.EOFError;
import com.wafflestudio.wall.components.elements.Wall;
import com.wafflestudio.wall.components.views.MainView;

public class MainController
{	
	private const defaultConfigFileName:String = "wallconf.xml";
	private var configFileName:String;
	private var _view:MainView;
	private var wallPath:File;
	private var configXML:XML;
	
	public function MainController(configFileName:String = defaultConfigFileName)  {
		this.configFileName = configFileName;
		this.configXML = loadConfig(configFileName);
		
		_view = new MainView(configXML.session[0]);
		
		trace(File.applicationStorageDirectory.nativePath);
	}
	
	public function saveConfig():void  {
		var file:File = File.applicationStorageDirectory.resolvePath( configFileName );
		var file_stream:FileStream = new FileStream();
		
		file_stream.open( file, FileMode.WRITE );
		file_stream.writeUTFBytes( this.toXML() );
		trace('saved at ' + file.nativePath);
	}
	
	public function get view():MainView
	{
		return _view;
	}
	
	public function saveCurrentWall():void  {
		var file:File = wallPath;
		var fileStream:FileStream = new FileStream();
		
		fileStream.open( file, FileMode.WRITE );
		fileStream.writeUTFBytes( currentWallXML );
		trace('saved at ' + file.nativePath);
	}
	
	public function loadWall(wallFile:File):void  {
		_view.addWall( wallFile );
		
	}
	
	public function addNewBlankSheet():void
	{
		_view.addBlankSheetToCurrentWall();
	}
	
	
	
	private function get defaultConfig():XML  {
		
		var configXML:XML = <infiniteWall/>;
			
		configXML.appendChild(MainView.defaultXML);
		
		return configXML;
	}
	
	private function toXML():XML  {
		var configXML:XML = <infiniteWall/>;	
		var sessionXML:XML = _view.toXML();
		configXML.appendChild(sessionXML);
			
		return configXML;
	}

	
	private function loadConfig(configFileName:String = defaultConfigFileName):XML  {
		
		var configXML:XML;
		
		try {
			var file:File = File.applicationStorageDirectory.resolvePath( configFileName );
			var fileStream:FileStream = new FileStream();
		
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
		
		return configXML;
	}
	
	private function get currentWallXML():XML  {
		return _view.getCurrentWallXML();
	}
	
	
	
	
}
}