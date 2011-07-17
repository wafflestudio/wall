package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class PanEvent extends Event implements IPanEvent
{
	public static const PANNING:String = "panning";
	public static const PANNED:String = "panned";
	
	private var _oldX:Number;
	private var _oldY:Number;
	private var _newX:Number;
	private var _newY:Number;
	
	public function get oldX():Number { return _oldX; }
	public function get oldY():Number { return _oldY; }
	public function get newX():Number { return _newX; }
	public function get newY():Number { return _newY; }
	
	public function PanEvent(dispatcher:IEventDispatcher, type:String, oldX:Number, oldY:Number, newX:Number, newY:Number)
	{
		super(dispatcher, type);
		_oldX = oldX;
		_oldY = oldY;
		_newX = newX;
		_newY = newY;
	}
}
}