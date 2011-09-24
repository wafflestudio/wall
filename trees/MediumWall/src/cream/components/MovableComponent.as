package cream.components
{
import flash.geom.Point;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import cream.eventing.events.MoveEvent;

public class MovableComponent extends Component implements IMovableComponent
{
	public function MovableComponent()
	{
		var initialPos:Point;
		var moveGlobalLocalDiff:Point;
		
		function moveStart(e:MouseEvent):void
		{
			initialPos = new Point(x,y);
			var moveStartPos:Point;
			
			e.stopPropagation();
			moveStartPos = (parent as IComponent).localToGlobal(initialPos);
			moveGlobalLocalDiff = moveStartPos.subtract(new Point(e.stageX, e.stageY));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
			stage.addEventListener(MouseEvent.MOUSE_UP, moveEnd);
		}
		
		function move(e:MouseEvent):void
		{
			var current:Point = (parent as IComponent).globalToLocal((new Point(e.stageX, e.stageY)).add(moveGlobalLocalDiff));
			var oldX:Number = x;
			var oldY:Number = y;
			
			x = current.x;
			y = current.y;
			
			dispatchMovingEvent(oldX, oldY, x, y);
		}
		
		function moveEnd(e:MouseEvent):void
		{
			var current:Point = (parent as IComponent).globalToLocal((new Point(e.stageX, e.stageY)).add(moveGlobalLocalDiff));
			var oldX:Number = x;
			var oldY:Number = y;
			x = current.x;
			y = current.y;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);	
			stage.removeEventListener(MouseEvent.MOUSE_UP, moveEnd);
			
			if(initialPos.x == x && initialPos.y == y)
				return;
			
			dispatchMovedEvent(initialPos.x, initialPos.y, x, y);
					
		}
		
		visualElement.addEventListener(MouseEvent.MOUSE_DOWN, moveStart);
		
		addMovingEventListener( function(e:MoveEvent):void
		{
			dispatchDimensionChangeEvent(new Rectangle(e.oldX, e.oldY, width, height), new Rectangle(e.newX, e.newY, width, height));
		});
		
		addMovedEventListener( function(e:MoveEvent):void
		{
			dispatchDimensionChangeEvent(new Rectangle(e.oldX, e.oldY, width, height), new Rectangle(e.newX, e.newY, width, height));
		});
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