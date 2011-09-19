package cream.eventing.events
{
	import cream.eventing.eventdispatchers.IEventDispatcher;

	public class TabCloseEvent extends CloseEvent
	{
		private var _index:int = -1;
		
		public function get index():int { return _index; }
	
		public function TabCloseEvent(dispatcher:IEventDispatcher, index:int)
		{
			super(dispatcher);
			_index = index;
		}
	}
}