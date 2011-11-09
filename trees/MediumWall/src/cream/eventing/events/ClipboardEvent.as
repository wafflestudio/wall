package cream.eventing.events
{
	import cream.eventing.eventdispatchers.IEventDispatcher;

	public class ClipboardEvent extends Event
	{
		public static const COPY:String = "copy";
		public static const CUT:String = "cut";
		public static const PASTE:String = "paste";
		
		public function ClipboardEvent(dispatcher:IEventDispatcher, type:String)
		{
			super(dispatcher, type);
		}
	}
}