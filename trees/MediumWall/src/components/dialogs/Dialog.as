package components.dialogs
{
import components.Component;
import components.popups.Popup;

import eventing.eventdispatchers.IDialogEventDispatcher;
import eventing.events.DialogEvent;

import mx.events.CloseEvent;

import spark.components.TitleWindow;

public class Dialog extends Popup implements IDialogEventDispatcher
{
	protected var tw:TitleWindow;
	
	public function Dialog()
	{
		tw = new TitleWindow();
		visualElement = tw;
		visualElementContainer = tw;
		
		tw.alpha = 0.8;
		tw.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void { close(); });
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