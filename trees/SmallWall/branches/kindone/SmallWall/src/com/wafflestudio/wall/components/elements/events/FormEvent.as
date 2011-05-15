package com.wafflestudio.wall.components.elements.events
{
import flash.events.Event;

public class FormEvent extends Event
{
	public static const CHANGE:String = "xmlChange";
	
	public var xml:XML;
	
	public function FormEvent(type:String, bubbles:Boolean=false, 
								  cancelable:Boolean=false, xml:XML = null)  {
		super(type, bubbles, cancelable);
		
		this.xml = xml;
	}
	
	
	override public function clone():Event  {
		var cloneEvent:FormEvent = new FormEvent(type, bubbles, 
			cancelable, xml);
		
		return cloneEvent;
	}
}
}