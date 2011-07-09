package components.scrollbars
{
	import mx.core.UIComponent;
	import spark.effects.Animate;
	import spark.effects.Fade;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.Sine;
	
	/**  스크롤바.
	 * 
	 * 스크롤바의 이동은 부모 노드의 스크롤 이벤트를 발생시킨다.
	 * 스크롤바의 이동은 부모 노드 영역에 의해 제한된다. 
	 * 
	 **/
	public class ScrollbarUIComponent extends UIComponent
	{
		protected static const defaultMaxOpacity:Number = 0.8;
		protected static const defaultFadeDurationMS:Number = 1000;
		protected static const defaultThickness:Number = 8;
		protected static const defaultPadding:Number = 2;
		
		public var fadeEffect:Fade;
		
		public function ScrollbarUIComponent()  {
			super();
			initFadeEffect();
		}
		
		public function show():void  {
			fadeEffect.stop();			
			this.alpha = 1.0;
		}
		
		public function hide():void  {
			fadeEffect.alphaTo = 0.0;
			fadeEffect.play();
		}
		
		private function initFadeEffect():void  {
			fadeEffect = new Fade(this);
			fadeEffect.duration = defaultFadeDurationMS;
			fadeEffect.easer = new Sine();		
		}
		
	}
}