package controllers  {

import components.Sheet;
import components.Wall;
import components.events.SpatialEvent;

import mx.core.Application;
import mx.core.FlexGlobals;
import mx.core.Window;
import mx.events.ResizeEvent;

import spark.components.WindowedApplication;



/** ApplicationController: 
 *
 * 싱글턴 클래스.
 * SHY!!
 * 
 * */
public class ApplicationController
{		
	
	/********* instance properties *********/
	
	/** Wall을 담는 배열 **/
	private var walls:Array = [];
	private var appWindow:WindowedApplication;
	
	public function ApplicationController(app:WindowedApplication)  {	
		init(app);
		start();
	}
	
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
		
	}
	
}
}