package component.control
{
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	
	import spark.effects.Animate;
	import spark.effects.animation.SimpleMotionPath;
	
	// idea: put scrollbar to maximum width at bottom (horizontal scrollbar)
	public class Scrollbar extends UIComponent
	{
		public function Scrollbar()
		{
			super();
		}
		
		public override function set width(value:Number):void
		{
			
			var anim:Animate = new Animate(this);
			var mpath:SimpleMotionPath = new SimpleMotionPath("super.width", null, value);
			anim.motionPaths.push(mpath);
			anim.duration = 1000;
			anim.play();
			
			//super.width(value);
			
		}
		
		
		
		public override function initialize():void
		{
			super.initialize();
			this.graphics.drawRect(
		}
	}
}