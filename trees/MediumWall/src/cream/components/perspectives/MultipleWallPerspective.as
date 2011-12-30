package cream.components.perspectives
{
import cream.components.sheets.Sheet;
import cream.components.walls.Wall;
import cream.eventing.eventdispatchers.ISelectionChangeEventDispatcher;
import cream.eventing.events.SelectionChangeEvent;

import flash.filesystem.File;

import mx.collections.ArrayCollection;

public class MultipleWallPerspective extends Perspective implements ISelectionChangeEventDispatcher
{	
	public function MultipleWallPerspective()
	{
		super();
	}
	
	public function get currentWall():Wall
	{
		trace('bad access');
		return null;	
	}
	
	public function addWall(wall:Wall):void
	{
		
	}
	
	public function addTextSheet(text:String = "", width:Number = 0, height:Number = 0):void
	{
		currentWall.addTextSheet(text, width, height);
	}
	
	public function addImageSheet(imageFile:File = null, width:Number = 0, height:Number = 0):void
	{
		currentWall.addImageSheet(imageFile, width, height);
	}
	
	protected function get currentIndex():int
	{
		return 0;		
	}
	
	protected function set currentIndex(val:int):void
	{
		// do nothing
	}
	
	public function addSelectionChangeEventListener(listener:Function):void
	{
		addEventListener(SelectionChangeEvent.SELECTION_CHANGE, listener);
	}
	
	public function removeSelectionChangeEventListener(listener:Function):void
	{
		removeEventListener(SelectionChangeEvent.SELECTION_CHANGE, listener);
	}
	
	
}
}