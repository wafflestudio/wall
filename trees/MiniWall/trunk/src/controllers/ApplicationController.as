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

public class ApplicationController
{
	private var appWindow:WindowedApplication;
	private var theWall:Wall;
	private var wallPath:File;
	
	public function ApplicationController(app:WindowedApplication)  {	
		this.appWindow = app;
		load();
	}
	
	public function newSheet():void
	{
		theWall.addBlankSheet();
	}
	
	private function loadconf():void  {
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
		
		if(confXML == null)
			confXML = loadDefaultConfXML();
		
		load();
	}
	
	
	public function changeWall():void  {
		var win:SelectWallDialog = new SelectWallDialog();
		
		win.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void  {
			PopUpManager.removePopUp(win);
		});
		
		
		
		PopUpManager.addPopUp(win as IFlexDisplayObject, appWindow);
		PopUpManager.centerPopUp(win);
	}

	public function load():void  {
		var file:File = 
			File.applicationStorageDirectory.resolvePath( "index.xml" );
		
		var file_stream:FileStream = new FileStream();
		var wallXML:XML;
		
		try {
			file_stream.open( file, FileMode.READ );
			var file_content:String = file_stream.readUTFBytes(file_stream.bytesAvailable)
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
			wallXML = loadDefaultXML();
		
		theWall = Wall.create(wallXML.wall[0]);	
		appWindow.addElement(theWall);
	}
	

	public function save():void  {
		var file:File = 
			File.applicationStorageDirectory.resolvePath( "wallrc" );
		
		var file_stream:FileStream = new FileStream();
		
		file_stream.open( file, FileMode.WRITE );
		file_stream.writeUTFBytes(this.toXML());
		trace('saved');
	}
	
	private function loadDefaultXML():XML  {
		var wallXML:XML = 
			<infinitewall>
			<wall width='200' height='200'>
				<sheet x='10' y='10' width='300' height='400' type='text'/>
				<sheet x='100' y='15' width='400' height='600' type='text'/>
			</wall>
			</infinitewall>
		return wallXML;
	}
	
	private function loadDefaultConfXML():XML  {
		var wallXML:XML = 
			<infinitewall>
			<wall width='200' height='200'>
				<sheet x='10' y='10' width='300' height='400' type='text'/>
				<sheet x='100' y='15' width='400' height='600' type='text'/>
			</wall>
			</infinitewall>
		return wallXML;
	}
	
	private function toXML():XML  {
		var xml:XML = <infintewall/>;
		
		for(var i:int  = 0; i < appWindow.numElements; i++)  {
			var element:Wall = appWindow.getElementAt(i) as Wall;
			if(element)
				xml.appendChild(element.toXML());
		}
		
		return xml;
	}
	

}
}