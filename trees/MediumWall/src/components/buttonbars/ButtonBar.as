package components.buttonbars
{
	import components.Component;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;

	public class ButtonBar extends Component
	{
		protected var hgroup:HGroup = new HGroup();
		
		override protected function get visualElement():IVisualElement
		{
			return hgroup;
		}
		
		public function ButtonBar()
		{
			super();
			
			visualElement = hgroup;
			visualElementContainer = hgroup;
			
//			group.addElement(button);
		}
		
		public function addButton():void
		{
			
		}
		
}