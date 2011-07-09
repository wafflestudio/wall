package components
{
import spark.components.Application;
import mx.core.IVisualElement;

public class ToplevelComponent extends Component implements IToplevelComponent
{
	public static var application:Application;
	
	public function ToplevelComponent()
	{
		super();
	}
	
	public function addToApplication(app:Application):void
	{
		application = app;
		app.addElement(this.visualElement);
	}
}
}