package cream.components.containers
{
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.display.Stage;
import flash.display.DisplayObject;
import cream.eventing.events.PanEvent;
import flash.geom.Rectangle;

public class PannableContainer extends ScrollableContainer implements IPannableContainer
{
	public function PannableContainer()
	{
		super();
		
		var initialPos:Point;
		var panStartPos:Point;
		var panGlobalLocalDiff:Point;
		
		function panStart(e:MouseEvent):void  {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, pan);
			stage.addEventListener(MouseEvent.MOUSE_UP, panEnd);
			initialPos = new Point(panX, panY);
			panStartPos = (visualElement as DisplayObject).localToGlobal( initialPos );
			panGlobalLocalDiff = panStartPos.subtract(new Point(e.stageX, e.stageY));
		}
		
		function pan(e:MouseEvent):void  {	
			var current:Point = (visualElement as DisplayObject).globalToLocal((new Point(e.stageX, e.stageY)).add(panGlobalLocalDiff));
			var oldX:Number = _panX;
			var oldY:Number = _panY;
			_panX = current.x;
			_panY = current.y;
			dispatchChildrenDimensionChangeEvent();
			dispatchDimensionChangeEvent(extent, extent);
			
			dispatchPanningEvent(oldX, oldY, _panX, _panY);
		}
		
		function panEnd(e:MouseEvent):void  {	
			var current:Point = (visualElement as DisplayObject).globalToLocal((new Point(e.stageX, e.stageY)).add(panGlobalLocalDiff));
			_panX = current.x;
			_panY = current.y;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan);
			stage.removeEventListener(MouseEvent.MOUSE_UP, panEnd);
			dispatchChildrenDimensionChangeEvent();
			dispatchDimensionChangeEvent(extent, extent);
			
			if(initialPos.x == _panX && initialPos.y == _panY)
				return;
			
			dispatchPannedEvent( initialPos.x, initialPos.y, _panX, _panY);
		}
		
		visualElement.addEventListener(MouseEvent.MOUSE_DOWN, panStart);

	}
	
	
	public function addPanningEventListener(listener:Function):void
	{
		addEventListener(PanEvent.PANNING, listener);
	}
	
	public function removePanningEventListener(listener:Function):void
	{
		removeEventListener(PanEvent.PANNING, listener);	
	}
	
	public function addPannedEventListener(listener:Function):void
	{
		addEventListener(PanEvent.PANNED, listener);
	}
	
	public function removePannedEventListener(listener:Function):void
	{
		removeEventListener(PanEvent.PANNED, listener);	
	}
	
	protected function dispatchPanningEvent(oldX:Number, oldY:Number, newX:Number, newY:Number):void
	{
		dispatchEvent(new PanEvent(this, PanEvent.PANNING, oldX, oldY, newX, newY));
	}
	
	protected function dispatchPannedEvent(oldX:Number, oldY:Number, newX:Number, newY:Number):void
	{
		dispatchEvent(new PanEvent(this, PanEvent.PANNED, oldX, oldY, newX, newY));
	}
	
	protected function set zoom(multiplier:Number):void
	{
		const MIN_SCALE:Number = 0.1;
		if(multiplier < 1.0 && (zoomX <= MIN_SCALE || zoomY <= MIN_SCALE))
		{
			multiplier = MIN_SCALE / (zoomX < zoomY ? 
				zoomY : zoomX);
			
			_zoomX = MIN_SCALE;
			_zoomY = MIN_SCALE;
		}
		else  {
			_zoomX = zoomX * multiplier;
			_zoomY = zoomY * multiplier;
		}
		
		_panX = (panX - width/2) * multiplier + width/2;
		_panY = (panY - height/2) * multiplier + height/2;
	}
	
	
	
	
}
}