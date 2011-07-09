package storages.history
{
import storages.actions.IAction;

public interface IHistory
{
	public function rollback():IAction;
	public function playForward():IAction;
	public function writeForward(action:IAction):void;
}
}