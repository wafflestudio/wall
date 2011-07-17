package components.controls
{

import components.IComponent;
import components.IPositionedComponent;
import components.IToplevelComponent;

public interface IControl extends IPositionedComponent,IToplevelComponent
{
	function get isActive():Boolean;	
}
}