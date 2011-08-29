package components.perspectives
{
import components.sheets.ISheet;
import components.walls.IWall;

import eventing.events.SelectionChangeEvent;

import mx.collections.ArrayCollection;

public class MultipleWallPerspective extends Perspective implements IMultipleWallPerspective
{	
	public function MultipleWallPerspective()
	{
		super();
	}
	
	public function get currentWall():IWall
	{
		return null;	
	}
	
	public function addWall(wall:IWall):void
	{
		
	}
	
	public function addSheet(option:String):void
	{
		var wall:IWall = currentWall;
		if(option == "text")
			wall.addBlankSheet();
		else if(option == "image")
			wall.addBlankSheet(option);
		else
			wall.addBlankSheet();
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