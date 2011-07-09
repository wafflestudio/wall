package eventing.events
{
import eventing.eventdispatchers.IEventDispatcher;

public class ScrollEvent extends ComponentEvent implements IScrollEvent
{
	public static const SCROLL:String = "scroll";
	
	private var hPos:Number;
	private var hLen:Number;
	private var vPos:Number;
	private var vLen:Number;
	
	public function get horitontalScrollPosRatio():Number { return hPos; }
	public function get horitontalScrollLengthRatio():Number { return hLen; }
	public function get verticalScrollPosRatio():Number { return vPos; }
	public function get verticalScrollLengthRatio():Number { return vLen; }
	
	public function ScrollEvent(dispatcher:IEventDispatcher, hPos:Number, hLen:Number, vPos:Number, vLen:Number)
	{
		super(dispatcher, SCROLL);
		this.hPos = hPos;
		this.hLen = hLen;
		this.vPos = vPos;
		this.vLen = vLen;
	}
}
}