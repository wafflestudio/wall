package components.sheets  {
import components.Component;
import spark.components.BorderContainer;
import storages.IXMLizable;
import components.MovableComponent;
import mx.core.IVisualElement;
import flash.events.MouseEvent;
import mx.core.IVisualElementContainer;
import eventing.events.FocusEvent;
import eventing.events.DimensionChangeEvent;
import flash.geom.Rectangle;
import eventing.events.CommitEvent;
import eventing.events.ResizeEvent;
import components.FlexibleComponent;


public class Sheet extends FlexibleComponent implements ISheet
{

	private var bc:BorderContainer = new BorderContainer();
	
	override protected function get visualElement():IVisualElement { return bc; }
	
	public function Sheet()
	{
		super();
		
		bc.setStyle("borderWidth", 1);
		
		// bring to front if clicked
		bc.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
			dispatchFocusInEvent();
		}, false, 1);
		
		visualElement = bc;
		visualElementContainer = bc;
	
		addDimensionChangeEventListener(function():void
		{
			dispatchCommitEvent();
		});
		
		
	}
	
	
	
	
	
	public function addContentChangeEventListener(listener:Function):void
	{
		addEventListener("contentChange", listener);
	}
	
	public function removeContentChangeEventListener(listener:Function):void
	{
		removeEventListener("contentChange", listener);
	}
	
	
	
	
	
	
	public function addCommitEventListener(listener:Function):void
	{
		addEventListener(CommitEvent.COMMIT, listener);	
	}
	
	public function removeCommitEventListener(listener:Function):void
	{
		removeEventListener(CommitEvent.COMMIT, listener);	
	}
	
	protected function dispatchCommitEvent():void
	{
		dispatchEvent(new CommitEvent(this));	
	}
	
	
	/**
	 * 	<sheet x="" y="" width="" height="">
	 * 	</sheet>
	 */ 
	public function fromXML(xml:XML):IXMLizable
	{
		reset();
		width = xml.@width;
		height = xml.@height;
		x = xml.@x;
		y = xml.@y;
		
		return this;
	}
	
	public function toXML():XML
	{
		var xml:XML = <sheet/>;
		xml.@width = width;
		xml.@height = height;
		xml.@x = x;
		xml.@y = y;
		
		return xml;
	}
	
	
	
}
}