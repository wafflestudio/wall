package cream.components.dialogs
{
	import cream.eventing.events.FileChooseEvent;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import mx.controls.Button;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;

	public class AlertDialog extends Dialog
	{
		private var _text:Label;
		
		public function AlertDialog()
		{
			super();
			tw.width = 400;
			tw.height = 200;
			title = "Alert";
			
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
			
			var ok:Button = new Button();
			ok.label = "OK";
			hg.addElement(ok);
			
			ok.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
				close();
				dispatchOKEvent();
			});
		
		}
		
		public function set text(value:String):void
		{
			_text.text = value;
		}
	}
}