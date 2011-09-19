package cream.eventing.events
{
	import cream.eventing.eventdispatchers.IEventDispatcher;

	public class DialogEvent extends Event
	{
		public static const CONFIRM:String = "confirm";
		public static const OK:String      = "ok";
		public static const CANCEL:String  = "cancel";
		
		public function DialogEvent(dispatcher:IEventDispatcher, type:String)
		{
			super(dispatcher, type);
		}
	}
}