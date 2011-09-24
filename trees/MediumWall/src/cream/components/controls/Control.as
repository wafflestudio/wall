package cream.components.controls
{
import cream.components.Component;
import cream.components.IPositionedComponent;
import cream.components.IToplevelComponent;
import cream.components.ToplevelComponent;
import mx.core.IVisualElementContainer;

import spark.components.Application;

public class Control extends ToplevelComponent implements IPositionedComponent
{
	private var active:Boolean = false;
	
	public function Control()
	{
		super();
	}

	public function set x(val:Number):void
	{
		visualElement.x = val;	
	}
	
	public function set y(val:Number):void
	{
		visualElement.y = val;	
	}
	
	public function get isActive():Boolean
	{
		return active;
	}
	
	override public function addToApplication(app:IVisualElementContainer = null):void
	{
		super.addToApplication(app);
		active = true;
	}
	
	override public function removeFromApplication(app:IVisualElementContainer = null):void
	{
		super.removeFromApplication(app);
		active = false;
		
	}
	
	public function bringToFront():void
	{
		if(parentApplication)
			parentApplication.setElementIndex(visualElement, parentApplication.numElements-1);
	}
	
}
}