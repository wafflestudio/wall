package cream.eventing.events
{
import cream.eventing.eventdispatchers.IEventDispatcher;

public class MouseEvent extends ComponentEvent
{

	public function MouseEvent(dispatcher:IEventDispatcher, type:String, localX:Number, localY:Number, stageX:Number, stageY:Number)
	{
		super(dispatcher, type);
		_localX = localX;
		_localY = localY;
		_stageX = stageX;
		_stageY = stageY;
	}
	
	private var _localX:Number;
	private var _localY:Number;
	private var _stageX:Number;
	private var _stageY:Number;
	
	public function get localX():Number { return _localX; }
	public function get localY():Number { return _localY; }
	public function get stageX():Number { return _stageX; }
	public function get stageY():Number { return _stageY; }
}
}