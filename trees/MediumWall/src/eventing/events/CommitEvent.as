package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class CommitEvent extends Event
{
	public static const COMMIT:String = "commit";
	
	private var _actionName:String;
	private var _args:Array = null;
	
	public function get actionName():String  {  return _actionName; }
	public function get args():Array  {  return _args;  }
	
	public function CommitEvent(dispatcher:IEventDispatcher, actionName:String, args:Array)
	{
		super(dispatcher, COMMIT);
		
		this._actionName = actionName;
		this._args = args;
	}
}
}