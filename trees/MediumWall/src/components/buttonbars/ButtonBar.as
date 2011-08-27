package components.buttonbars
{
	import components.Component;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.components.Button;
	import spark.components.Group;

	public class ButtonBar extends Component
	{
		protected var group:Group = new Group();
		
		override protected function get visualElement():IVisualElement
		{
			return group;
		}
		
		public function ButtonBar()
		{
			super();
			
			visualElement = group;
			
//			group.addElement(button);
			
		}
		
		public function set label(text:String):void
		{
			var button:spark.components.Button = visualElement as spark.components.Button;
			button.label = text;	
		}
		
		public function set enabled(value:Boolean):void
		{
			var button:spark.components.Button = visualElement as spark.components.Button;
			button.enabled = value;
		}
	}
}