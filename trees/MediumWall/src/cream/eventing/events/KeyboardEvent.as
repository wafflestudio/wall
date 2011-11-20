package cream.eventing.events
{
	import cream.eventing.eventdispatchers.IEventDispatcher;
	
	public class KeyboardEvent extends Event
	{
		public static const DELETE_KEY:String = "delete_key";
		public static const COPY_KEY:String = "cut_key";
		public static const PASTE_KEY:String = "paste_key";
		public static const CUT_KEY:String = "cut_key";
		
		public function KeyboardEvent(dispatcher:IEventDispatcher, type:String=DEFAULT)
		{
			super(dispatcher, type);
		}
	}
}