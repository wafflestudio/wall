package cream.components.contents
{
	import eventing.events.ActionCommitEvent;
	import eventing.events.CommitEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.IVisualElement;
	
	import spark.components.TextArea;
	import spark.events.TextOperationEvent;
	
	import storages.IXMLizable;
	import storages.actions.Action;
	import storages.actions.IActionCommitter;
	
	public class TextContent extends Content implements ITextContent, IActionCommitter
	{
		// actions
		public static const TEXT_CHANGE:String = "TEXT_CHANGE";
		
		protected var textarea:TextArea = new TextArea;
		protected var _text:String = "";
		
		protected function get text():String { return _text; }
		protected function set text(value:String):void { textarea.text = _text = value; }
		
		override protected function get visualElement():IVisualElement { return textarea; }
		
		public function TextContent()
		{
			super();

			textarea.percentWidth = 100;
			textarea.percentHeight = 100;
			
			// ignore consecutive textchange as a commit. commit only the last one
			var delayedTextChangeTimer:Timer = new Timer(300, 1);
			var textChangeArgs:Array = [];
			
			delayedTextChangeTimer.addEventListener(TimerEvent.TIMER, function():void
			{
				dispatchCommitEvent(new ActionCommitEvent(self, TEXT_CHANGE, textChangeArgs));
				_text = textarea.text;
			});
			
			textarea.addEventListener(TextOperationEvent.CHANGE, function(e:TextOperationEvent):void
			{
				textChangeArgs = [new String(text), textarea.text];
				delayedTextChangeTimer.reset();
				delayedTextChangeTimer.start();
			});
		}
		
		public function applyAction(action:Action):void
		{
			switch(action.type)
			{
				case TEXT_CHANGE:
					text = action.args[1];
					break;
			}
		}
		
		public function revertAction(action:Action):void
		{
			switch(action.type)
			{
				case TEXT_CHANGE:
					text = action.args[0];
					break;
			}
		}
		
		
		
		/**
		 * 	<content>
		 * 		<text text="...">
		 * 	</content>
		 */ 
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
		
			var textXML:XML = <text/>;
			textXML.@text = textarea.text;
			xml.appendChild(textXML);
			
			return xml;
		}
		
		override public function fromXML(xml:XML):IXMLizable {
			
			var textxml:XML = xml.text[0];
			textarea.text = textxml.@text;
			return this;
		}
		public function getTextData():String {
			return textarea.text;
		}
	}
}