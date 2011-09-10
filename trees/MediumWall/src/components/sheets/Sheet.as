package components.sheets  {
	import components.Component;
	import components.FlexibleComponent;
	import components.ICommitableComponent;
	import components.MovableComponent;
	import components.contents.ImageContent;
	import components.contents.TextContent;
	
	import eventing.eventdispatchers.IClickEventDispatcher;
	import eventing.eventdispatchers.IEventDispatcher;
	import eventing.eventdispatchers.ISheetEventDispatcher;
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


public class Sheet extends FlexibleComponent implements IXMLizable,ISheetEventDispatcher,ICommitableComponent
{

	private var bc:BorderContainer = new BorderContainer();
	override protected function get visualElement():IVisualElement { return bc; }
	private var tc:TextContent;
	private var ic:ImageContent;

	public function Sheet(option:String=null)
	{
		super();
		tc = new TextContent();
		ic = new ImageContent();
		if(option=="image")
		{
			bc.addElement(  ic._protected_::visualElement);
		} else if(option == "text")
		{
			bc.addElement(  tc._protected_::visualElement);
		}else {
			bc.addElement(  ic._protected_::visualElement);
			bc.addElement(  tc._protected_::visualElement);
		}

		bc.setStyle("borderWidth", 1);
		
		// bring to front if clicked
		bc.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
			dispatchFocusInEvent();
		}, false, 1);
		
		visualElement = bc;
		visualElementContainer = bc;
	
		addDimensionChangeEventListener(function(e:DimensionChangeEvent):void
		{
			dispatchCommitEvent(self, DimensionChangeEvent.DIMENSION_CHANGE, [e.oldDimension, e.dimension]);
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
	
	protected function dispatchCommitEvent(dispatcher:IEventDispatcher, actionName:String, args:Array):void
	{
		dispatchEvent(new CommitEvent(dispatcher, actionName, args));	
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
		
		if(xml.child("content")[0] != null) {
			var contentXML:XML = xml.content[0];
			if(contentXML.child("image").length() == 1) {
				ic.fromXML(contentXML);
				bc.addElement(tc._protected_::visualElement);
			} else if (contentXML.child("text").length() == 1) {
				tc.fromXML(contentXML);
				bc.addElement(ic._protected_::visualElement);
			} else {
			}
		}
		return this;
	}
	
	public function toXML():XML
	{
		var xml:XML = <sheet/>;
		xml.@width = width;
		xml.@height = height;
		xml.@x = x;
		xml.@y = y;
		if(this.ic.getBitmapData() != null) {
			xml.appendChild(ic.toXML());
		}
		if(this.tc.getTextData() != "") {
			xml.appendChild(tc.toXML());	
		}
		return xml;
	}
	
	
	
}
}