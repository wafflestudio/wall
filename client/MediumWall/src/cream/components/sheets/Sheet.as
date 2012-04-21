/** ## Sheet라고 한다. **/

package cream.components.sheets  {

	import cream.components.FlexibleComponent;
	import cream.components.controls.CloseControl;
	import cream.eventing.eventdispatchers.ICloseEventDispatcher;
	import cream.eventing.eventdispatchers.ISheetEventDispatcher;
	import cream.eventing.events.ActionCommitEvent;
	import cream.eventing.events.ClickEvent;
	import cream.eventing.events.CloseEvent;
	import cream.eventing.events.CommitEvent;
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
	import flash.utils.Timer;
	import mx.binding.utils.BindingUtils;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import resources.Assets;
	
	import spark.components.BorderContainer;
	import spark.effects.Fade;
	import spark.filters.DropShadowFilter;



public class Sheet extends FlexibleComponent implements IXMLizable,ISheetEventDispatcher,IActionCommitter, ICloseEventDispatcher
{
    /** Actions **/
	public static const MOVE:String = "MOVE";
	public static const RESIZE:String = "RESIZE";

    /** Sheet Types **/
	public static const IMAGE_SHEET:String = "image";
	public static const TEXT_SHEET:String = "text";

    protected var bc:BorderContainer;
    override protected function get visualElement():IVisualElement {  return bc;  }
    override protected function get visualElementContainer():IVisualElementContainer	{  return bc;	}

    private var closeControl:CloseControl = new CloseControl();

    protected var type:String;

    /** Factory methods -> **/
    public static function createSheetByType(type:String):Sheet
    {
        var newSheet:Sheet;
        if(type == Sheet.IMAGE_SHEET)
            newSheet = new ImageSheet();
        else if(type == Sheet.TEXT_SHEET)
            newSheet = new TextSheet();

        return newSheet;
    }
    
    public static function createImageSheet(imageFile:File):Sheet
    {
        var newSheet:ImageSheet = new ImageSheet();
        newSheet.file = imageFile;
        return newSheet;
    }

    public static function createTextSheet(text:String):Sheet
    {
        var newSheet:TextSheet = new TextSheet();
        newSheet.text = text;
        return newSheet;
    }

    /** <- Factory methods **/

	
	/** Constructor **/
	public function Sheet(type:String)
	{
		super();
		
		this.type = type;

	}

    override protected function initUnderlyingComponents():void
    {
        bc = new BorderContainer();
        closeControl.imageSource = new Assets.close_png();

        bc.setStyle("borderWeight", 0);
        bc.setStyle("borderAlpha", 0);

        // bring to front if clicked
        bc.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
            dispatchFocusInEvent();
            bringSystemFocus();
        }, false, 1);


        addMovedEventListener( function(e:MoveEvent):void
        {
            dispatchCommitEvent(new ActionCommitEvent(self, MOVE, [e.oldX, e.oldY, e.newX, e.newY]));
        });

        addResizedEventListener( function(e:ResizeEvent):void
        {
            dispatchCommitEvent(new ActionCommitEvent(self, RESIZE, [e.oldLeft, e.oldTop, e.oldRight, e.oldBottom, e.left, e.top, e.right, e.bottom]));

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
//		reset();
		width = xml.@width;
		height = xml.@height;
		x = xml.@x;
		y = xml.@y;
		type = xml.@type;

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

		return xml;
	}
	

	
}
}