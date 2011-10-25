package cream.components.buttons
{
	import cream.components.ClickableComponent;
	import cream.components.controls.CloseControl;
	import cream.eventing.eventdispatchers.ICloseEventDispatcher;
	import cream.eventing.events.ClickEvent;
	import cream.eventing.events.CloseEvent;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.ButtonBarButton;
	import spark.components.Group;
	import spark.components.TextInput;

	public class TabButton extends ClickableComponent implements ICloseEventDispatcher
	{
		private var button:ButtonBarButton = new ButtonBarButton();
		private var closeControl:CloseControl = new CloseControl();
		
		
		public function TabButton()
		{
			super();
			
			button.addEventListener(MouseEvent.CLICK, 
				function(e:MouseEvent):void {
					dispatchClickEvent(new ClickEvent(self));
				}
			);
			button.addEventListener(MouseEvent.RIGHT_CLICK,
				function(e:MouseEvent):void {
					// To do : change code
					var here = e.currentTarget;
					var textInput:TextInput = new TextInput();
					textInput.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent):void {
						if (e.keyCode == 13)
						{
							here.label = textInput.text;
							here.name = textInput.text;
							here.parent.removeElement(textInput);
						}
					});
					
					e.currentTarget.parent.addElement(textInput);
				}
			);
			var detachTimer:Timer = new Timer(100);
			var closeControlShowing:Boolean = false;
			var timerPaused:Boolean = false;
			
			detachTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
			{
				if(closeControlShowing)  {
					closeControl.removeFromApplication();
					closeControlShowing = false;
				}
			});
			
			
			button.addEventListener(MouseEvent.ROLL_OVER, 
				function ():void
				{
					if(detachTimer.running)  {
						detachTimer.stop();
						detachTimer.reset();
					}
					
					if(!closeControlShowing)  {
						closeControl.addToApplication();
						closeControlShowing = true;
					}
					
					var pt:Point = localToGlobal(new Point(width-16,0));
					closeControl.x = pt.x;
					closeControl.y = pt.y;
					
				}
			);
			
			button.addEventListener(MouseEvent.ROLL_OUT, 
				function ():void
				{
					if(closeControlShowing && !detachTimer.running)
						detachTimer.start();
					
				}
			);
			
			closeControl.addRollOverEventListener( function():void
				{
					if(detachTimer.running)  {
						detachTimer.stop();
						timerPaused = true;
					}
				}
			);
			
			closeControl.addRollOutEventListener( function():void
				{
					if(timerPaused)  {
						detachTimer.start();
						timerPaused = false;
					}
				}
			);
			
			closeControl.addClickEventListener( function(e:ClickEvent):void 
				{
					dispatchCloseEvent();
				}
			);
			
			
			visualElement = button;
			visualElementContainer = null;
			
			
			
		}
		
		public function set label(text:String):void
		{
			button.label = text;	
		}
		
		public function set selected(value:Boolean):void
		{
			button.selected = value;
		}
		
		public function get selected():Boolean
		{
			return button.selected;
		}
		
		public function addCloseEventListener(listener:Function):void
		{
			addEventListener(CloseEvent.CLOSE, listener);
		}
		
		public function removeCloseEventListener(listener:Function):void
		{
			removeEventListener(CloseEvent.CLOSE, listener);
		}
		
		protected function dispatchCloseEvent():void
		{
			dispatchEvent(new CloseEvent(this));
		}
	}
}