package component
{
	import mx.events.ResizeEvent;
	import spark.components.BorderContainer;
	import utils.IScrollable;
	
	
	/** Wall: 벽 컴포넌트
	 * 
	 * 시트를 담는다 (contain) - sheetadded, sheetdestroyed
	 * 
	 * 스크롤한다 (scroll) - scrolling, scrolled
	 * 
	 * 줌 인/아웃이 된다.(휠, 핀치) zooming zoomed
	 * 
	 * 몇 개의 벽이 겹쳐진다
	 * 
	 * 생성되고 보여지고 파괴된다. create destroy  
	 * 
	 * */
	public class Wall extends BorderContainer implements IScrollable/**, IZoomable **/
	{
		private var contentWidthHolder : Number;
		private var contentHeightHolder : Number;
		
		public function Wall()  {
			super();
		}
		
		public override function initialize():void  {
			this.setStyle("borderColor", 0x0);
			this.setStyle("backgroundColor", 0xF2F2F2);
			
			contentWidthHolder = width;
			contentHeightHolder = height;
		}
		
		public function set contentWidth(value:Number):void	 {
			if(contentWidthHolder == value)
				return;
			contentWidthHolder = value;
		
		}
		
		public function set contentheight(value:Number):void  {
			if(contentHeightHolder == value)
				return ;
			contentHeightHolder = value;
			// display scrollbar
			// reposiion scrollbar
			// height(value);	
		}
		
		protected override function createChildren():void  {
			
			// add scrollbar
		}
	}
}