package cream.components.buttonbars
{
	import cream.components.Component;
	import cream.components.buttons.TabButton;
	import cream.components.dialogs.ConfirmDialog;
	
	import cream.eventing.eventdispatchers.ICloseEventDispatcher;
	import cream.eventing.eventdispatchers.ISelectionChangeEventDispatcher;
	import cream.eventing.events.ClickEvent;
	import cream.eventing.events.CloseEvent;
	import cream.eventing.events.DialogEvent;
	import cream.eventing.events.SelectionChangeEvent;
	import cream.eventing.events.TabCloseEvent;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.components.Group;
	import spark.components.HGroup;

	public class TabBar extends Component implements ISelectionChangeEventDispatcher, ICloseEventDispatcher
	{
		private var _selectedIndex:int = -1;
		protected var hgroup:HGroup = new HGroup();
		
		override protected function get visualElement():IVisualElement  {  return hgroup;  }
		
		public function TabBar(buttonsByLabel:Array = null)
		{
			super();
			
			hgroup.gap = 0;
			visualElement = hgroup;
			visualElementContainer = hgroup;
		}
		
		
		private function onButtonClicked(e:ClickEvent):void
		{
			var btn:TabButton = e.dispatcher as TabButton;
			
			if(btn == null)
				return;
			
			var index:int = getChildIndex(btn);
			dispatchSelectionChangeEvent(_selectedIndex, index);
			selectedIndex = index;
		}
		
		private function onButtonClosed(e:CloseEvent):void
		{
			var btn:TabButton = e.dispatcher as TabButton;
			
			if(btn == null)
				return;
			
			var dialog:ConfirmDialog = new ConfirmDialog();
			dialog.text = "Do you really want to close this tab?";
			dialog.show();
			dialog.addConfirmEventDispatcher( function(e:DialogEvent):void
			{
				dispatchCloseEvent(getChildIndex(btn));	
			});
			
		}
		
		public function addButton(btn:TabButton):void
		{
			if(btn == null)
				return;
			
			addChild(btn);
			
			btn.addClickEventListener( onButtonClicked );
			btn.addCloseEventListener( onButtonClosed );
			
			if(numChildren == 1)
				selectedIndex = 0;
		}
		
		public function removeButton(btn:TabButton):void
		{
			if(btn == null)
				return;
			
			btn.removeCloseEventListener( onButtonClosed );
			btn.removeClickEventListener( onButtonClicked );
			removeChild(btn);
		}
		
		public function buttonAt(index:int):TabButton
		{
			if(index < 0 || index >= children.length)
				return null;
			
			return children[index];
		}
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		public function set selectedIndex(index:int):void
		{
			
			if(_selectedIndex != index)  {
				_selectedIndex = index;
				
				for(var i:int = 0; i < numChildren; i++) 
				{
					(children[i] as TabButton).selected = (index == i) ? true : false;
				}
			}
			
		}
		
		public function addSelectionChangeEventListener(listener:Function):void
		{
			addEventListener(SelectionChangeEvent.SELECTION_CHANGE, listener);
		}
		
		public function removeSelectionChangeEventListener(listener:Function):void
		{
			removeEventListener(SelectionChangeEvent.SELECTION_CHANGE, listener);
		}
		
		public function addCloseEventListener(listener:Function):void
		{
			addEventListener(CloseEvent.CLOSE, listener);
		}
		
		public function removeCloseEventListener(listener:Function):void
		{
			removeEventListener(CloseEvent.CLOSE, listener);
		}
		
		
		protected function dispatchSelectionChangeEvent(oldIndex:int, newIndex:int):void
		{
			dispatchEvent(new SelectionChangeEvent(this, oldIndex, newIndex));
		}
		
		protected function dispatchCloseEvent(index:int):void
		{
			dispatchEvent(new TabCloseEvent(this, index));
		}
		
	}
		
}