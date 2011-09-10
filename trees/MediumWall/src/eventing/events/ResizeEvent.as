package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class ResizeEvent extends ComponentEvent
{
	public static const RESIZING:String = "resizing";
	public static const RESIZED:String = "resized";
	
	private var _oldTop:Number;
	private var _oldLeft:Number;
	private var _oldRight:Number;
	private var _oldBottom:Number;
	
	private var _top:Number;
	private var _left:Number;
	private var _right:Number;
	private var _bottom:Number;
	
	public function get oldTop():Number { return _oldTop;	}
	public function get oldLeft():Number {	return _oldLeft; }
	public function get oldRight():Number { return _oldRight;	}
	public function get oldBottom():Number { return _oldBottom; }
	
	public function get top():Number { return _top;	}
	public function get left():Number {	return _left; }
	public function get right():Number { return _right;	}
	public function get bottom():Number { return _bottom; }
	
	public function ResizeEvent(dispatcher:IEventDispatcher, type:String, oldLeft:Number, oldTop:Number, 
		oldRight:Number, oldBottom:Number, left:Number, top:Number, right:Number, bottom:Number)
	{
		super(dispatcher, type);
		_oldTop = oldTop;
		_oldBottom = oldBottom;
		_oldLeft = oldLeft;
		_oldRight = oldRight;
		
		_top = top;
		_bottom = bottom;
		_left = left;
		_right = right;
	}
}
}