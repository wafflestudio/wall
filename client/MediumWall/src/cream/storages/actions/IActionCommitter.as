package cream.storages.actions
{
	public interface IActionCommitter
	{
		function applyAction(action:Action):void;
		function revertAction(action:Action):void;
	}
}