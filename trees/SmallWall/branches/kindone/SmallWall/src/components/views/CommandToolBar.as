package components.views
{
import spark.components.BorderContainer;
import mx.controls.Image;
import spark.components.HGroup;

public class CommandToolBar extends HGroup
{
	public function CommandToolBar()
	{
		this.height = 48 + 16;
		this.percentWidth = 100;
		this.alpha = 0.8;
		
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		var addbtn:Image = new Image();		
		var savebtn:Image = new Image(); 
		
		addbtn.load("plus.png");
		this.addElement(addbtn);
		savebtn.load("save.png");
		this.addElement(savebtn);
		
		

	}
}
}