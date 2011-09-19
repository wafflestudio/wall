package cream.eventing.events
{
import cream.eventing.eventdispatchers.IEventDispatcher;

public class SelectionChangeEvent extends Event
{
	public static const SELECTION_CHANGE:String = "selectionChange";

	private var _oldSelectedIndex:int = 0;
	private var _oldSelectedItem:Object = null;
	private var _selectedIndex:int = 0;
	private var _selectedItem:Object = null;
	
	public function get selectedIndex():int {  return _selectedIndex; }
	public function get selectedItem():Object { return _selectedItem; }
	public function get oldSelectedIndex():int {  return _oldSelectedIndex; }
	public function get oldSelectedItem():Object { return _oldSelectedItem; }
	
	public function SelectionChangeEvent(dispatcher:IEventDispatcher, oldSelectedIndex:int, selectedIndex:int, 
										 oldSelectedItem:Object = null, selectedItem:Object = null)
	{
		super(dispatcher, SELECTION_CHANGE);
		_oldSelectedIndex = oldSelectedIndex;
		_selectedIndex = selectedIndex;
		
		_oldSelectedItem = selectedItem;
		_selectedItem = selectedItem;
	}

	
	
}
}