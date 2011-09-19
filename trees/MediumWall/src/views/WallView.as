package views
{
	import cream.components.walls.FileStoredWall;
	import components.walls.IFileStoredWall;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import spark.components.Button;
	import spark.components.View;
	
	import storages.IFileReference;
	import storages.actions.Action;
	
	import utils.TemporaryFileStorage;
	import utils.XMLFileStream;

	public class WallView extends View implements IFileReference
	{
		private var _file:File;
		private var wall:IFileStoredWall;
		private var loaded:Boolean = false;
		
		private var addSheetBtn:Button = new Button();
		
		public function WallView()
		{
			addSheetBtn.label = "+";
			
			actionContent = [addSheetBtn];
			
			addSheetBtn.addEventListener(MouseEvent.CLICK, function():void
			{
				wall.addBlankSheet();	
			});
		}
		
		public function get file():File
		{
			return _file;
		}

		override public function set data(value:Object):void
		{
			var filePath:String = value as String;
		
			super.data = value;
		
			if(loaded)  {
				trace('Should not try to set data more than once');
				return;
			}
			
			if(filePath)  {
				_file = File.applicationStorageDirectory.resolvePath(filePath);
				wall = new FileStoredWall(_file);
			}
			else  {
				wall = new FileStoredWall();
				_file = wall.file;
			}
			
			
			wall.addToApplication(this);
		
			loaded = true;
			
		}
		
		
	}
}