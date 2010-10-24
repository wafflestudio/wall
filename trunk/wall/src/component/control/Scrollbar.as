package component.control
{
	import mx.core.UIComponent;
	
	import spark.effects.Animate;
	import spark.effects.Fade;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.Sine;
	
	/**  스크롤바.
	 * 
	 * 평상시에는 희미하게 보이거나 잘 보이지 않다가 스크롤을 동작시킬때 보임
	 * 
	 * 스크롤바의 이동은 부모 노드의 스크롤 이벤트를 발생시킨다.
	 * 스크롤바의 이동은 부모 노드 영역에 의해 제한된다. 
	 * 
	 **/
	public class Scrollbar extends UIComponent
	{
		private static const anim_duration_ms:int = 200;
		private static const max_opacity:Number = 0.8;
		
		public var fadeEffect:Fade;
		
		public function Scrollbar()  {
			super();
			fadeEffect = new Fade(this);
			fadeEffect.duration = 1000;
			fadeEffect.easer = new Sine();
		}
		
		public override function initialize():void  {
			super.initialize();	
		}
		
		public function show():void  {
			fadeEffect.stop();			
			this.alpha = 1.0;
		}
		
		public function hide():void  {
			fadeEffect.alphaTo = 0.2;
			fadeEffect.play();
		}
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void  {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			this.graphics.clear();
			this.graphics.beginFill(0x0, max_opacity);
			this.graphics.drawRoundRect(0,0, unscaledWidth, unscaledHeight,5,5);	
			this.graphics.endFill();	
		}
	}
}