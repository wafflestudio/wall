package controllers  {

import components.Sheet;
import components.Wall;
import components.events.SpatialEvent;
import mx.core.Application;
import mx.core.FlexGlobals;
import mx.core.Window;
import mx.events.ResizeEvent;
import spark.components.WindowedApplication;
import flash.filesystem.FileMode;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.utils.setTimeout;



/** ApplicationController: 
 *
 * */
public class ApplicationController
{		
	
	/** public methods **/
	/********************************************************************/
	public function ApplicationController(app:WindowedApplication)  {	
		init(app);
		start();
	}
	/********************************************************************/

	
	/********* instance properties *********/
	/** Wall을 담는 배열 **/
	private var walls:Array = [];
	private var appWindow:WindowedApplication;
	
	
	/** private methods **/
	private function init(app:WindowedApplication):void  {
		this.appWindow = app;
	}
	
	private function start():void  {
		var wallXML:XML = 
			<wall width='200' height='200'>
				<sheet x='10' y='10' width='300' height='400'/>
				<sheet x='100' y='15' width='400' height='600'/>
			</wall>
		var wall:Wall = Wall.create(wallXML);	
		appWindow.addElement(wall);
		
		setTimeout(save, 2000);
	}
	
	private function save():void  {
		var file:File = 
			File.applicationStorageDirectory.resolvePath( "wallrc" );
		
		var file_stream:FileStream = new FileStream();
		
		file_stream.open( file, FileMode.WRITE );
		
		//var file_str:String = file_stream.readMultiByte( file.size, File.systemCharset );
		file_stream.writeUTFBytes(getWallXML());
	}
	
	private function getWallXML():XML  {
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