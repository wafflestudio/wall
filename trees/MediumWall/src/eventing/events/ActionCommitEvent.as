package eventing.events
{
	import eventing.eventdispatchers.IEventDispatcher;

	public class ActionCommitEvent extends CommitEvent
	{	
		public function ActionCommitEvent(dispatcher:IEventDispatcher, actionName:String, args:Array)
		{
			super(dispatcher, actionName, args);
		}
	}
}