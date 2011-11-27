/** ## Sheet라고 한다. **/

package cream.components.sheets  {
	import cream.components.Component;
	import cream.components.Composite;
	import cream.components.FlexibleComponent;
	import cream.components.ICommitableComponent;
	import cream.components.MovableComponent;
	import cream.components.containers.Container;
	import cream.components.contents.ImageContent;
	import cream.components.contents.TextContent;
	import cream.components.controls.CloseControl;
	import cream.components.walls.Wall;
	import cream.eventing.eventdispatchers.IClickEventDispatcher;
	import cream.eventing.eventdispatchers.ICloseEventDispatcher;
	import cream.eventing.eventdispatchers.IEventDispatcher;
	import cream.eventing.eventdispatchers.ISheetEventDispatcher;
	import cream.eventing.events.ActionCommitEvent;
	import cream.eventing.events.ClickEvent;
	import cream.eventing.events.CloseEvent;
	import cream.eventing.events.CommitEvent;
	import cream.eventing.events.CompositeEvent;
	import cream.eventing.events.DimensionChangeEvent;
	import cream.eventing.events.FocusEvent;
	import cream.eventing.events.MoveEvent;
	import cream.eventing.events.ResizeEvent;
	import cream.storages.IXMLizable;
	import cream.storages.actions.Action;
	import cream.storages.actions.IActionCommitter;
	import cream.utils.Platform;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import flashx.textLayout.events.UpdateCompleteEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.components.BorderContainer;
	import spark.effects.Fade;
	import spark.filters.DropShadowFilter;



public class Sheet extends FlexibleComponent implements IXMLizable,ISheetEventDispatcher,IActionCommitter, ICloseEventDispatcher
{
	public static const MOVE:String = "MOVE";
	public static const RESIZE:String = "RESIZE";
	
	public static const IMAGE_SHEET:String = "image";
	public static const TEXT_SHEET:String = "text";
	
	private var bc:BorderContainer = new BorderContainer();
	override protected function get visualElement():IVisualElement { return bc; }
	
	private var textContent:TextContent;
	private var imageContent:ImageContent;
	private var closeControl:CloseControl = new CloseControl();
	
	private var type:String;
	
	/** Factory methods **/
	public static function createImageSheet(imageFile:File):Sheet
	{
		var newSheet:Sheet = new Sheet(IMAGE_SHEET);
		newSheet.imageContent.file = imageFile;
		return newSheet;
	}
	
	public static function createTextSheet(text:String):Sheet
	{
		var newSheet:Sheet = new Sheet(TEXT_SHEET);
		newSheet.textContent.text = text;
		return newSheet;	
	}
	
	/** Constructor **/
	public function Sheet(type:String)
	{
		super();
		
		this.type = type;
	
		if(type == IMAGE_SHEET)
		{
			imageContent = new ImageContent();
			bc.addElement(imageContent._protected_::visualElement);
			
			imageContent.addCommitEventListener( function(e:CommitEvent):void
			{
				dispatchCommitEvent(e);
			});
			
		} 
		else if(type == TEXT_SHEET)
		{
			textContent = new TextContent();
			bc.addElement(textContent._protected_::visualElement);
			textContent.addCommitEventListener( function(e:CommitEvent):void
			{
				dispatchCommitEvent(e);
			});
		} 
		
		bc.setStyle("borderWeight", 0);
		bc.setStyle("borderAlpha", 0);

		// bring to front if clicked
		bc.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
			dispatchFocusInEvent();
			bringSystemFocus();
		}, false, 1);
		
		visualElement = bc;
		visualElementContainer = bc;
	
		
		addMovedEventListener( function(e:MoveEvent):void
		{
			
			dispatchCommitEvent(new ActionCommitEvent(self, MOVE, [e.oldX, e.oldY, e.newX, e.newY]));
		});
		
		addResizedEventListener( function(e:ResizeEvent):void
		{
			dispatchCommitEvent(new ActionCommitEvent(self, RESIZE, [e.oldLeft, e.oldTop, e.oldRight, e.oldBottom, e.left, e.top, e.right, e.bottom]));
			if(type == Sheet.IMAGE_SHEET) {
				imageContent.width = e.right - e.left;
				imageContent.height = e.bottom - e.top;	
			}
			
		});
		
		addAddedEventListener( function():void
		{
			dispatchFocusInEvent();
		});
		
		addRemovedEventListener( function():void
		{
			dispatchFocusOutEvent();
		});
		
		
		/** Close Control **/
		var detachTimer:Timer = new Timer(400);
		var closeControlShowing:Boolean = false;
		var timerPaused:Boolean = false;
		
		/** update close control position **/
		function updateCloseControlPosition():void {
			var pt:Point = localToGlobal(new Point(width, 0));
			closeControl.x = pt.x;
			closeControl.y = pt.y-closeControl.height;
		}
		
		BindingUtils.bindSetter(updateCloseControlPosition, bc, "x");
		BindingUtils.bindSetter(updateCloseControlPosition, bc, "y");
		BindingUtils.bindSetter(updateCloseControlPosition, bc, "width");
		BindingUtils.bindSetter(updateCloseControlPosition, bc, "height");
		
		addExternalDimensionChangeEventListener(updateCloseControlPosition);
		
		function removeCloseControl():void
		{
			if(closeControlShowing)  {
				closeControl.removeFromApplication();
				closeControlShowing = false;
			}
		}
		
		function showCloseControl():void
		{
			if(!closeControlShowing)  {
				closeControl.addToApplication();
				var effect:Fade = new Fade(closeControl._protected_::visualElement);
				effect.alphaFrom = 0;
				effect.alphaTo = 1.0;
				effect.play();
				closeControlShowing = true;
			}
		}
		
		detachTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
		{
			removeCloseControl();
		});
		
		
		bc.addEventListener(MouseEvent.ROLL_OVER, 
			function ():void
			{
				
				if(detachTimer.running)  {
					detachTimer.stop();
					detachTimer.reset();
				}
				
				showCloseControl();
				
				updateCloseControlPosition();
				
			}
		);
		
		bc.addEventListener(MouseEvent.ROLL_OUT, 
			function ():void
			{
				if(closeControlShowing && !detachTimer.running)
					detachTimer.start();
				
			}
		);
		
		
		// hide close control when dragging the sheet
		addMovingEventListener( function(e:MoveEvent):void
		{
			removeCloseControl();
		});
		
		addMovedEventListener( function(e:MoveEvent):void
		{
			showCloseControl();
		});
		
		closeControl.addRollOverEventListener( 
			function():void
			{
				if(detachTimer.running)  {
					detachTimer.stop();
					timerPaused = true;
				}
			}
		);
		
		closeControl.addRollOutEventListener( 
			function():void
			{
				if(timerPaused)  {
					detachTimer.start();
					timerPaused = false;
				}
			}
		);
		
		closeControl.addClickEventListener( 
			function(e:ClickEvent):void 
			{
				dispatchCloseEvent();
			}
		);
		
		addRemovedEventListener( 
			function():void
			{
				removeCloseControl();
			}
		);
		
		
		// shadow effect
		bc.filters = [new DropShadowFilter(12, 45,0, 0.4, 30, 30, 0.8)];
		
		// delete key dispatches close event
		bc.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void
		{
			if(Platform.isMac && e.keyCode == 46)
			{
				dispatchCloseEvent();
			}
		});

	}
	
	
	public override function set width(val:Number):void
	{
		if(imageContent)
			imageContent.width = val;
		super.width = val;
	}
	
	public override function set height(val:Number):void
	{
		if(imageContent)
			imageContent.height = val;
		super.height = val;
	}

	
	public function addContentChangeEventListener(listener:Function):void
	{
		addEventListener("contentChange", listener);
	}
	
	public function removeContentChangeEventListener(listener:Function):void
	{
		removeEventListener("contentChange", listener);
	}
	
	
	public function addCloseEventListener(listener:Function):void
	{
		addEventListener(CloseEvent.CLOSE, listener);
	}
	
	public function removeCloseEventListener(listener:Function):void
	{
		removeEventListener(CloseEvent.CLOSE, listener);
	}
	
	
	
	public function addCommitEventListener(listener:Function):void
	{
		addEventListener(CommitEvent.COMMIT, listener);	
	}
	
	public function removeCommitEventListener(listener:Function):void
	{
		removeEventListener(CommitEvent.COMMIT, listener);	
	}
	
	
	
	protected function dispatchCloseEvent():void
	{
		dispatchEvent(new CloseEvent(this));
	}

	
	public function applyAction(action:Action):void
	{
		switch(action.type)
		{
			case MOVE:
				
				x = action.args[2];
				y = action.args[3];
				dispatchFocusInEvent();

				break;
			case RESIZE:
				
				x = action.args[4];
				y = action.args[5];
				resize(action.args[6] - action.args[4], action.args[7] - action.args[5]);

				dispatchFocusInEvent();
				break;
		}
	}
	
	public function revertAction(action:Action):void
	{
		switch(action.type)
		{
			case MOVE:
			
				x = action.args[0];
				y = action.args[1];
				dispatchFocusInEvent();

				break;
			case RESIZE:
				
				x = action.args[0];
				y = action.args[1];
				resize(action.args[2] - action.args[0], action.args[3] - action.args[1]);

				dispatchFocusInEvent();
				break;
		}
		
	}
	
	protected function dispatchCommitEvent(e:CommitEvent):void
	{
		dispatchEvent(e);	
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
		type = xml.@type;
		
		if(xml.child("content")[0] != null) {
			var contentXML:XML = xml.content[0];
			if(type == IMAGE_SHEET) {
				imageContent.fromXML(contentXML);
				imageContent.width = width;
				imageContent.height = height;
//				imageContent.setSize(width, height);
			} else if (type == TEXT_SHEET) {
				textContent.fromXML(contentXML);
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
		xml.@type = type;
		
		if(type == IMAGE_SHEET) {
			xml.appendChild(imageContent.toXML());
		}
		else if(type == TEXT_SHEET) {
			xml.appendChild(textContent.toXML());	
		}
		return xml;
	}
	

	
}
}