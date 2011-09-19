package cream.storages.actions
{


public class Action
{
	public var type:String;
	public var committer:IActionCommitter;
	public var args:Array;
	
	
	public function Action(type:String, committer:IActionCommitter, args:Array)
	{
		this.type = type;
		this.committer = committer;
		this.args = args;
	}
}
}