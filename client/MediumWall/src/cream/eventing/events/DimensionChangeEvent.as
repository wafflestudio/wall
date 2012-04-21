package cream.eventing.events
{
import flash.geom.Rectangle;
import cream.eventing.eventdispatchers.IEventDispatcher;

public class DimensionChangeEvent extends ComponentEvent
{
	public static const DIMENSION_CHANGE:String = "dimensionChange";
	
	private var _dimension:Rectangle;
	private var _oldDimension:Rectangle;
	
	public function get dimension():Rectangle { return _dimension; }
	public function get oldDimension():Rectangle { return _dimension; }
	
	public function DimensionChangeEvent(dispatcher:IEventDispatcher, oldRect:Rectangle, newRect:Rectangle)
	{
		super(dispatcher, DIMENSION_CHANGE);
		
		this._oldDimension = oldRect;
		this._dimension = newRect;
	}
}
}