package components
{
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import spark.components.Application;

public class ToplevelComponent extends Component implements IToplevelComponent
{
	public static var application:IVisualElementContainer;
	
	public function ToplevelComponent()
	{
		super();
	}
	
	public function addToApplication(app:IVisualElementContainer):void
	{
		application = app;
		app.addElement(this.visualElement);
	}
	
	public function removeFromApplication(app:IVisualElementContainer = null):void
	{
		if(app)
			app.removeElement(this.visualElement);
		else
			(this.visualElement.parent as Application).removeElement(this.visualElement);
	}
}
}