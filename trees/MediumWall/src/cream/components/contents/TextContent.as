package cream.components.contents
{
	import cream.eventing.events.ActionCommitEvent;
	import cream.eventing.events.CommitEvent;
	import cream.storages.IXMLizable;
	import cream.storages.actions.Action;
	import cream.storages.actions.IActionCommitter;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import skins.BlankSkin;
	
	import spark.components.TextArea;
	import spark.components.supportClasses.Skin;
	import spark.events.TextOperationEvent;

	
	public class TextContent extends Content implements IActionCommitter
	{
		// actions
		public static const TEXT_CHANGE:String = "TEXT_CHANGE";
		
		protected var textarea:TextArea = new TextArea;
		protected var _text:String = "";

        override protected function get visualElement():IVisualElement {  return textarea;  }
        override protected function get visualElementContainer():IVisualElementContainer	{  return null;	}

		public function get text():String { return _text; }
		public function set text(value:String):void { textarea.text = _text = value; }
		
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
			
			textarea.setStyle('skinClass', BlankSkin);

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
	}
}