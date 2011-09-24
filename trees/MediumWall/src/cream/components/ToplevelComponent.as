package cream.components
{
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import spark.components.Application;

public class ToplevelComponent extends Component implements IToplevelComponent
{	
	protected var parentApplication:IVisualElementContainer;
	
	
	public function ToplevelComponent()
	{
		super();
	}
	
	public function addToApplication(app:IVisualElementContainer = null):void
	{
		if(!app)
			app = application;
		
		parentApplication = app;
		app.addElement(this.visualElement);
	}
	
	public function removeFromApplication(app:IVisualElementContainer = null):void
	{
		if(!app)
			app = application;

		parentApplication = null;
		app.removeElement(this.visualElement);
		
	}
}
}