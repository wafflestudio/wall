package cream.components.dialogs
{
	
	import eventing.eventdispatchers.IDialogEventDispatcher;
	
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.controls.Label;
	
	import spark.components.HGroup;
	import spark.components.VGroup;

	public class ConfirmDialog extends Dialog
	{
		private var _text:Label;
		
		public function ConfirmDialog()
		{
			super();
			tw.width = 400;
			tw.height = 100;
			title = "Confirm";
			
			var vg:VGroup = new VGroup();
			vg.percentWidth = 100;
			vg.percentHeight = 100;
			tw.addElement(vg);
			
			_text = new Label();
			
			vg.addElement(_text);
			
			var hg:HGroup = new HGroup();
			hg.percentWidth = 100;
			hg.height = 30;
			hg.horizontalAlign = "center";
			vg.addElement(hg);
			
			var accept:Button = new Button();
			accept.label = "Accept";
			hg.addElement(accept);
			
			accept.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
				close();
				dispatchConfirmEvent();
			});
			
			var cancel:Button = new Button();
			cancel.label = "Cancel";
			hg.addElement(cancel);
			
			cancel.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
				close();
				dispatchCancelEvent();
			});
		}
		
		public function set text(value:String):void
		{
			_text.text = value;
		}
		
	}
}