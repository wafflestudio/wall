package components.controls
{
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;

public class ResizeControl extends Control implements IResizeControl
{
	private var resizeUIComponent:ResizeControlUIComponent;
	private var upperLeft:UIComponent = new UIComponent();
	private var upperRight:UIComponent = new UIComponent();
	private var lowerLeft:UIComponent = new UIComponent();
	private var lowerRight:UIComponent = new UIComponent();
	private var up:UIComponent = new UIComponent();
	private var left:UIComponent = new UIComponent();
	private var right:UIComponent = new UIComponent();
	private var down:UIComponent = new UIComponent();
	
	override protected function get visualElement():IVisualElement { return resizeUIComponent; }
	override protected function get visualElementContainer():IVisualElementContainer { return null; }
	
	public function ResizeControl()
	{
		super();
		resizeUIComponent = new ResizeControlUIComponent();
		
		visualElement = resizeUIComponent;
		visualElementContainer = null;
	}
	
	override public function set width(val:Number):void
	{
		super.width = val;
	}
	
	override public function set height(val:Number):void
	{
		super.height = val;
	}
}
}