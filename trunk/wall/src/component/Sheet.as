package component
{
	import component.event.SpatialEvent;
	
	import flash.events.Event;
	
	import spark.components.BorderContainer;
	
	import utils.IDisposable;
	import utils.IDraggable;

	/** Sheet: 시트 컴포넌트. 
	 * 
	 * Wall상에 놓이고 컨텐트를 담는다 
	 * 
	 * 벽 상에서 움직이고, (moving, moved)
	 * 사이즈가 조절되고 	(resizing, resized)
	 * 컨텐트 줌 인/아웃이 된다  (zooming, zommed)
	 * 
	 * 시트 자체로 드래그가 되고
	 * 리사이즈 컨트롤이 부착되어 있고
	 * 줌 컨트롤이 부착되어 있다
	 * 
	 * 생성과 삭제
	 * 
	 * */
	[Event(name="moving", type="flash.events.Event")]
	[Event(name="moved", type="flash.events.Event")]
	[Event(name="resizing", type="flash.events.Event")]
	[Event(name="resized", type="flash.events.Event")]
	[Event(name="zooming", type="flash.events.Event")]
	[Event(name="zoomed", type="flash.events.Event")]
	public class Sheet extends BorderContainer implements IDraggable/**, IResizable, IZoomable **/
	{
		/** drag기능 인클루드 **/
		include "../utils/FDrag.as"
		
		public function Sheet()  {
			
		}
		
		private function initMoveEvent():void  {
			/** 드래그 기능 초기화 **/
			dragInit();
			
			this.addEventListener(DragEvent.DRAG,
				function(e:DragEvent):void { 
					dispatchEvent(new SpatialEvent(SpatialEvent.MOVING,
						false, false, e.x, e.y)); 
				} 
			);
			
			this.addEventListener(DragEvent.DRAG_END,
				function(e:DragEvent):void { 
					dispatchEvent(new SpatialEvent(SpatialEvent.MOVED,
						false,false, e.x, e.y)); 
				} 
			);	
		}
		
		private function initResizeEvent():void  {
			
		}
		
		private function initZoomEvent():void  {
			
		}
		
		
		/** initialize()
		 * 
		 * 컴포넌트 초기화
		 * 
		 * initialize sevents
		 *  
		 * 
		 **/
		public override function initialize():void  {
			initMoveEvent();
			initResizeEvent();
			initZoomEvent();
		}
		
		/** createChildren:
		 * 
		 * 자식 노드 생성
		 * 
		 * */
		protected override function createChildren():void  {
			
		}
		
		
		
	}
}