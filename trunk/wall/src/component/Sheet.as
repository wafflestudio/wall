package component
{
	import component.event.SpatialEvent;
	
	import flash.events.Event;
	
	import spark.components.BorderContainer;
	
	import utils.IDisposable;
	import utils.IDraggable;

	[Event(name="moving", type="flash.events.Event")]
	[Event(name="moved", type="flash.events.Event")]
	public class Sheet extends BorderContainer implements IDraggable
	{
		include "../utils/FDrag.as"
		
		public function Sheet()
		{
			dragInit();
			this.addEventListener(DragEvent.DRAG,
				function(e:DragEvent):void { 
					dispatchEvent(new SpatialEvent(SpatialEvent.MOVING,false,
						false, e.x, e.y)); 
				} 
			);
			this.addEventListener(DragEvent.DRAG_END,
				function(e:DragEvent):void { 
					dispatchEvent(new SpatialEvent(SpatialEvent.MOVED,false,
					false, e.x, e.y)); 
				} 
			);
			
		}
	}
}