package controller
{
	import component.Sheet;
	import component.Wall;
	import component.event.SpatialEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.ResizeEvent;
	
	import spark.components.WindowedApplication;
	
	public class ApplicationController
	{		
		
		private var walls:Array = [];
		
		public static function init():void
		{
			var app:WindowedApplication = FlexGlobals.topLevelApplication as 
				spark.components.WindowedApplication;
			var wall:Wall = new Wall();
			app.addElement( wall );
			wall.width = app.width;
			wall.height = app.height;
			instance.walls.push(wall);	
			
			app.addEventListener(ResizeEvent.RESIZE, updateWallDimension);
			
			
		
		}
		
		private static function updateWallDimension(e:ResizeEvent):void
		{
			var app:WindowedApplication = FlexGlobals.topLevelApplication as 
				spark.components.WindowedApplication;
			
			var wall:Wall = instance.walls[0] as Wall;
			wall.width = app.width;
			wall.height = app.height;
		}
		
		
		public function ApplicationController() {	}
		
		private static var _instance:ApplicationController = null;
		
		private static function get instance():ApplicationController
		{
			if(_instance == null)
				_instance = new ApplicationController();
			return _instance;
		}
	}
}