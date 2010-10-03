package component.control
{
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	
	import spark.effects.Animate;
	import spark.effects.animation.SimpleMotionPath;
	
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
		public function Scrollbar()  {
			super();
		}
		
		public override function set width(value:Number):void  {
			var anim:Animate = new Animate(this);
			var mpath:SimpleMotionPath = new SimpleMotionPath("super.width", null, value);
			anim.motionPaths.push(mpath);
			anim.duration = 1000;
			anim.play();
		}
		
		public override function initialize():void  {
			super.initialize();	
		}
	}
}