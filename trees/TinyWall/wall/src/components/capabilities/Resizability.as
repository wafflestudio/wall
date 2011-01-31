package components.capabilities
{
	import components.SpatialObject;
	import components.controls.IResizable;
	import components.controls.ResizeControl;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.UIComponent;

public class Resizability
{
	private var resizeControl:ResizeControl;
	
	public function Resizability(target:IResizable)
	{
		this.resizeControl = new ResizeControl(target);
	}
	
}
}