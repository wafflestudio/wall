package components.perspectives
{
import components.walls.Wall;

import eventing.eventdispatchers.ISelectionChangeEventDispatcher;
import eventing.events.SelectionChangeEvent;

import mx.collections.ArrayCollection;

public class MultipleWallPerspective extends Perspective implements ISelectionChangeEventDispatcher
{	
	public function MultipleWallPerspective()
	{
		super();
	}
	
	public function get currentWall():Wall
	{
		return null;	
	}
	
	public function addWall(wall:Wall):void
	{
		
	}
	
	public function addSheet(option:String):void
	{
		var wall:Wall = currentWall;
		if(option)
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