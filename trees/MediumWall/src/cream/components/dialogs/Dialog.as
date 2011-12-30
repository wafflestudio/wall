package cream.components.dialogs
{
import cream.components.Component;
import cream.components.popups.Popup;

import cream.eventing.eventdispatchers.IDialogEventDispatcher;
import cream.eventing.events.DialogEvent;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import mx.events.CloseEvent;

import spark.components.TitleWindow;

public class Dialog extends Popup implements IDialogEventDispatcher
{
	protected var tw:TitleWindow;

    override protected function get visualElement():IVisualElement {  return tw;  }
    override protected function get visualElementContainer():IVisualElementContainer	{  return tw;	}

	
	public function Dialog()
	{
        super();

        visualElement.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void { close(); });
	}

    override protected function initUnderlyingComponents():void
    {
        tw = new TitleWindow();
        tw.alpha = 0.8;
    }
	
	public function set title(text:String):void
	{
		tw.title = text;	
	}
	
	public function close():void
	{
		hide();	
	}
	
	public function addConfirmEventDispatcher(listener:Function):void
	{
		addEventListener(DialogEvent.CONFIRM, listener);
	}
	
	public function removeConfirmEventDispatcher(listener:Function):void
	{
		removeEventListener(DialogEvent.CONFIRM, listener);
	}
	
	public function addOKEventDispatcher(listener:Function):void
	{
		addEventListener(DialogEvent.OK, listener);
	}
	
	public function removeOKEventDispatcher(listener:Function):void
	{
		removeEventListener(DialogEvent.OK, listener);
	}
	
	public function addCancelEventDispatcher(listener:Function):void
	{
		addEventListener(DialogEvent.CANCEL, listener);
	}
	
	public function removeCancelEventDispatcher(listener:Function):void
	{
		removeEventListener(DialogEvent.CANCEL, listener);
	}
	
	protected function dispatchConfirmEvent():void
	{
		dispatchEvent(new DialogEvent(this, DialogEvent.CONFIRM));	
	}
	
	protected function dispatchOKEvent():void
	{
		dispatchEvent(new DialogEvent(this, DialogEvent.OK));	
	}
	
	protected function dispatchCancelEvent():void
	{
		dispatchEvent(new DialogEvent(this, DialogEvent.CANCEL));	
	}
}
}