package components.containers
{
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.display.Stage;
import flash.display.DisplayObject;

public class PannableContainer extends ScrollableContainer implements IPannableContainer
{
	public function PannableContainer()
	{
		super();
		
		var panStartPos:Point;
		var panGlobalLocalDiff:Point;
		
		function panStart(e:MouseEvent):void  {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, pan);
			stage.addEventListener(MouseEvent.MOUSE_UP, panEnd);
			
			panStartPos = (visualElement as DisplayObject).localToGlobal(new Point(panX, panY));
			panGlobalLocalDiff = panStartPos.subtract(new Point(e.stageX, e.stageY));
		}
		
		function pan(e:MouseEvent):void  {	
			var current:Point = (visualElement as DisplayObject).globalToLocal((new Point(e.stageX, e.stageY)).add(panGlobalLocalDiff));
			panX = current.x;
			panY = current.y;
			
			dispatchChildrenDimensionChangeEvent();
		}
		
		function panEnd(e:MouseEvent):void  {	
			var current:Point = (visualElement as DisplayObject).globalToLocal((new Point(e.stageX, e.stageY)).add(panGlobalLocalDiff));
			panX = current.x;
			panY = current.y;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, pan);
			stage.removeEventListener(MouseEvent.MOUSE_UP, panEnd);
			dispatchChildrenDimensionChangeEvent();
		}
		
		visualElement.addEventListener(MouseEvent.MOUSE_DOWN, panStart);
	}
	
	
	
	
	
	
	
}
}