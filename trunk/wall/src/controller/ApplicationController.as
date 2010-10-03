package controller
{
	import component.Sheet;
	import component.Wall;
	import component.event.SpatialEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.ResizeEvent;
	
	import spark.components.WindowedApplication;
	
	/** ApplicationController: 
	 * 
	 * 어플리케이션 초기화와 큰틀의 변경 사항을 책임진다 
	 * 
	 * 모든 초기화와 로드 작업을 진행
	 * 싱글턴 클래스.
	 * 
	 * */
	public class ApplicationController
	{		
		/** Wall을 담는 배열 **/
		private var walls:Array = [];
		
		public function ApplicationController()  {	
		
		}

		public static function get appWindow():WindowedApplication  {
			return FlexGlobals.topLevelApplication as WindowedApplication;
		}
		
		private static var instanceHolder:ApplicationController = null;
		
		private static function get instance():ApplicationController  {
			if(instanceHolder == null)
				instanceHolder = new ApplicationController();
			return instanceHolder;
		}

		private static function updateWallDimension(e:ResizeEvent):void  {
			var wall:Wall = instance.walls[0] as Wall;
			wall.width = appWindow.width;
			wall.height = appWindow.height;
		}
		
		public static function init():void	{
			/** 초기화:
			 * 계정 로드
			 * 벽 로드
			 * 어플리케이션 이벤트에 동작하도록 초기화
			 * */
			var wall:Wall = new Wall();
			appWindow.addElement( wall );
			wall.width = appWindow.width;
			wall.height = appWindow.height;
			instance.walls.push(wall);	
			
			appWindow.addEventListener(ResizeEvent.RESIZE, updateWallDimension);
		}
	}
}