package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class ResizeEvent extends ComponentEvent
{
	public static const RESIZING:String = "resizing";
	public static const RESIZED:String = "resized";
	
	private var _top:Number;
	private var _left:Number;
	private var _right:Number;
	private var _bottom:Number;
	
	public function get top():Number
	{
		return _top;
	}
	
	public function get left():Number
	{
		return _left;
	}
	
	public function get right():Number
	{
		return _right;
	}
	
	public function get bottom():Number
	{
		return _bottom;
	}
	
	public function ResizeEvent(dispatcher:IEventDispatcher, type:String, left:Number, top:Number, right:Number, bottom:Number)
	{
		super(dispatcher, type);
		_top = top;
		_bottom = bottom;
		_left = left;
		_right = right;
	}
}
}