package components.buttons
{
import components.ClickableComponent;
import components.Component;

import eventing.events.ClickEvent;

import flash.events.MouseEvent;

import mx.core.IVisualElement;

import spark.components.Button;

public class Button extends ClickableComponent
{
	private var button:spark.components.Button = new spark.components.Button();
	
	override protected function get visualElement():IVisualElement
	{
		return button;
	}
	
	public function Button()
	{
		super();
		var self:Button = this;
	
		button.addEventListener(MouseEvent.CLICK, 
			function(e:MouseEvent):void {
				dispatchClickEvent(new ClickEvent(self));
			}
		);
	}
		
	public function set label(text:String):void
	{
		var button:spark.components.Button = visualElement as spark.components.Button;
		button.label = text;	
	}
	
	public function set enabled(value:Boolean):void
	{
		var button:spark.components.Button = visualElement as spark.components.Button;
		button.enabled = value;
	}
}
}