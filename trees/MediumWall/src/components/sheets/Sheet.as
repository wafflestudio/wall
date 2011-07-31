package components.sheets  {
	import components.Component;
	import components.FlexibleComponent;
	import components.MovableComponent;
	import components.contents.ImageContent;
	import components.contents.TextContent;
	
	import eventing.eventdispatchers.IClickEventDispatcher;
	import eventing.events.CommitEvent;
	import eventing.events.DimensionChangeEvent;
	import eventing.events.FocusEvent;
	import eventing.events.ResizeEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.components.BorderContainer;
	
	import storages.IXMLizable;


public class Sheet extends FlexibleComponent implements ISheet
{

	private var bc:BorderContainer = new BorderContainer();
	override protected function get visualElement():IVisualElement { return bc; }
	private var tc:TextContent;
	private var ic:ImageContent;

	public function Sheet()
	{
		super();
		tc = new TextContent();
		ic = new ImageContent();
		
		addChildTo(bc, tc);
		addChildTo(bc, ic);

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
	 * 		<content>
	 * 			...
	 * 		</content>
	 * 	</sheet>
	 */ 
	public function fromXML(xml:XML):IXMLizable
	{
		reset();
		width = xml.@width;
		height = xml.@height;
		x = xml.@x;
		y = xml.@y;
		
		
		var contentXML:XML = xml.content[0];
		if(contentXML)
			tc.fromXML(contentXML);
		
		return this;
	}
	
	public function toXML():XML
	{
		var xml:XML = <sheet/>;
		xml.@width = width;
		xml.@height = height;
		xml.@x = x;
		xml.@y = y;
		
		xml.appendChild(tc.toXML());	
		
		return xml;
	}
	
	
	
}
}