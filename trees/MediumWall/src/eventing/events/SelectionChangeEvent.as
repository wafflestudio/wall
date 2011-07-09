package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class SelectionChangeEvent extends Event implements ISelectionChangeEvent
{
	public static const SELECTION_CHANGE:String = "selectionChange";

	private var _selectedIndex:int = 0;
	private var _selectedItem:Object = null;
	
	public function SelectionChangeEvent(dispatcher:IEventDispatcher, index:int, item:Object)
	{
		super(dispatcher, SELECTION_CHANGE);
		_selectedIndex = index;
		_selectedItem = item;
	}

	
	public function get selectedIndex():int
	{
		return _selectedIndex;
	}
	public function get selectedItem():Object
	{
		return _selectedItem;
	}
}
}