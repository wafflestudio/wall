package components
{
import flash.geom.Point;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import eventing.events.MoveEvent;

public class MovableComponent extends Component implements IMovableComponent
{
	public function MovableComponent()
	{
		var old:Point;
		var moveGlobalLocalDiff:Point;
		
		function moveStart(e:MouseEvent):void
		{
			old = new Point(x,y);
			var moveStartPos:Point;
			
			e.stopPropagation();
			moveStartPos = (parent as IComponent).localToGlobal(old);
			moveGlobalLocalDiff = moveStartPos.subtract(new Point(e.stageX, e.stageY));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
			stage.addEventListener(MouseEvent.MOUSE_UP, moveEnd);
		}
		
		function move(e:MouseEvent):void
		{
			var current:Point = (parent as IComponent).globalToLocal((new Point(e.stageX, e.stageY)).add(moveGlobalLocalDiff));
			dispatchDimensionChangeEvent(new Rectangle(x, y, width, height), new Rectangle(current.x, current.y, width, height));
			
			x = current.x;
			y = current.y;
			
			dispatchMovingEvent(old.x, old.y, x, y);
		}
		
		function moveEnd(e:MouseEvent):void
		{
			var current:Point = (parent as IComponent).globalToLocal((new Point(e.stageX, e.stageY)).add(moveGlobalLocalDiff));
			
			dispatchDimensionChangeEvent(new Rectangle(x, y, width, height), new Rectangle(current.x, current.y, width, height));
			
			x = current.x;
			y = current.y;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);	
			stage.removeEventListener(MouseEvent.MOUSE_UP, moveEnd);
			dispatchMovedEvent(old.x, old.y, x, y);
					
		}
		
		visualElement.addEventListener(MouseEvent.MOUSE_DOWN, moveStart);
	}
	
	
	public function set x(val:Number):void
	{
		visualElement.x = val;
	}
	
	public function set y(val:Number):void
	{
		visualElement.y = val;
	}
	
	public function addMovingEventListener(listener:Function):void
	{
		addEventListener(MoveEvent.MOVING, listener);
	}
	
	public function removeMovingEventListener(listener:Function):void
	{
		removeEventListener(MoveEvent.MOVING, listener);
	}
	
	public function addMovedEventListener(listener:Function):void
	{
		addEventListener(MoveEvent.MOVED, listener);
	}
	
	public function removeMovedEventListener(listener:Function):void
	{
		removeEventListener(MoveEvent.MOVED, listener);
	}
	
	protected function dispatchMovingEvent(oldX:Number, oldY:Number, newX:Number, newY:Number):void
	{
		dispatchEvent(new MoveEvent(this, MoveEvent.MOVING, oldX, oldY, newX, newY));
	}
	
	protected function dispatchMovedEvent(oldX:Number, oldY:Number, newX:Number, newY:Number):void
	{
		dispatchEvent(new MoveEvent(this, MoveEvent.MOVED, oldX, oldY, newX, newY));
	}
	
}
}