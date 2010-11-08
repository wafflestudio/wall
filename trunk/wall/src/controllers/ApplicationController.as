package controllers  {
	
import components.Plane;
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
	public static function get appWindow():WindowedApplication  {
		return instance.appWindow;
	}
	
	public static function init(app:WindowedApplication):void	{
		instance.init(app);
	}
	
	public static function start():void  {
		instance.start();
	}  
	
	
	private static var instanceHolder:ApplicationController = null;
	
	private static function get instance():ApplicationController  {
		if(instanceHolder == null)
			instanceHolder = new ApplicationController();
		return instanceHolder;
	}
	
	
	
	/********* instance properties *********/
	
	/** Wall을 담는 배열 **/
	private var walls:Array = [];
	private var appWindow:WindowedApplication;

	
	public function ApplicationController()  {	
		if(instanceHolder)
			throw new Error("Tried to create already initialized singleton class");
	}
	
	private function init(app:WindowedApplication):void  {
		this.appWindow = app;
	}
	
	private function start():void  {
		var wallXML:XML = 
			<wall width='1000' height='1000'>
				<sheet x='10' y='10' width='300' height='400'/>
				<sheet x='100' y='15' width='400' height='600'/>
			</wall>
		var wall:Wall = Wall.create(wallXML);	
		appWindow.addElement(wall);
		
		var plane:Plane = new Plane();
	}
	
}
}