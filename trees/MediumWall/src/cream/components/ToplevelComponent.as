package cream.components
{
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import spark.components.Application;

public class ToplevelComponent extends Component implements IToplevelComponent
{
	
	public function ToplevelComponent()
	{
		super();
	}
	
	public function addToApplication(app:IVisualElementContainer = null):void
	{
		if(!app)
			app = application;
		

		app.addElement(this.visualElement);
	}
	
	public function removeFromApplication(app:IVisualElementContainer = null):void
	{
		if(!app)
			app = application;

		app.removeElement(this.visualElement);
		
	}
}
}