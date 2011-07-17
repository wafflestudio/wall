package components.perspectives
{
import mx.collections.ArrayCollection;
import components.walls.IWall;
import components.sheets.ISheet;
import eventing.events.SelectionChangeEvent;

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
	
	public function addSheet():void
	{
		var wall:IWall = currentWall;
				
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