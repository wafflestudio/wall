package storages.history
{
import storages.actions.Action;

public interface IHistory
{
	function rollback():Action;
	function playForward():Action;
	function writeForward(action:Action):void;
}
}