package components.views
{
import spark.components.BorderContainer;

public class MainView extends BorderContainer
{
	public function MainView()
	{
	}
	
	override public function initialize():void
	{
		super.initialize();
		this.percentHeight = this.percentWidth = 100;
	}
	
	override protected function createChildren():void  {
		super.createChildren();
		var toolbar = new CommandToolBar();
		this.addElement(toolbar);
		
	}
}
}