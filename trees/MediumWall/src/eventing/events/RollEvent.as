package eventing.events
{
	import eventing.eventdispatchers.IEventDispatcher;
	
	public class RollEvent extends Event
	{
		
		public static const ROLL_OUT:String = "ROLL_OUT";
		public static const ROLL_OVER:String = "ROLL_OVER";
		
		public function RollEvent(dispatcher:IEventDispatcher, type:String=DEFAULT)
		{
			super(dispatcher, type);
		}
	}
}