package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class MoveEvent extends ComponentEvent
{
	public static const MOVING:String = "moving";
	public static const MOVED:String = "moved";
	
	private var _newX:Number;
	private var _newY:Number;
	private var _oldX:Number;
	private var _oldY:Number;
	
	public function get oldX():Number { return _oldX; }
	public function get oldY():Number { return _oldY; }
	public function get newX():Number { return _newX; }
	public function get newY():Number { return _newY; }
	
	public function MoveEvent(dispatcher:IEventDispatcher, type:String, oldX:Number, oldY:Number, newX:Number, newY:Number)
	{
		super(dispatcher, type);
		_newX = newX;
		_newY = newY;
		_oldX = oldX;
		_oldY = oldY;
	}
	
	
}
}