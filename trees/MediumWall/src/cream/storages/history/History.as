package cream.storages.history
{
import mx.collections.ArrayCollection;
import cream.storages.actions.Action;

/**
 * Usage:
 * 	var history = new History();
 *  history.writeForward(action);
 *  var action = history.rollback();
 *  action.type
 * 
 */
public class History
{
	private var log:ArrayCollection;
	private var cursor:int;
	private function get length():int { return log.length; }
	
	public function History()
	{
		log = new ArrayCollection([]);
		cursor = 0;
	}
	
	public function rollback():Action
	{
		if(cursor <= 0)  {
			trace("Already at the beginning of history");
			return null;
		}
		// [H](c=1)
		// (c=0)[H]
		var entry:Action = log[cursor-1];
		cursor --;
		
		return entry;
	}
	
	public function playForward():Action
	{
		if(cursor >= length)  {
			trace("Already at the end of history");
			return null;
		}
		// (c=0)[H]
		// [H](c=1)
		var entry:Action = log[cursor];
		cursor ++;
		return entry;
	}
	
	public function writeForward(action:Action):void
	{
		// (c=0)[H]
		// [H](c=1)
		
		// (c=0)
		// [H](c=1)
		var entry:Action = action;
		log.addItemAt(entry, cursor);
		cursor ++;
		 
		while(cursor < log.length)  
			log.removeItemAt(cursor);
		
	}
	
}
}