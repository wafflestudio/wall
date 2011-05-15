package com.wafflestudio.wall.components.elements.interfaces
{
import flash.events.IEventDispatcher;
import mx.core.IVisualElement;

public interface IScrollable extends IEventDispatcher
{
	function get width():Number;
	function get height():Number;
	function get horizontalScrollPosRatio():Number;
	function get horizontalScrollLengthRatio():Number;
	function get verticalScrollPosRatio():Number;
	function get verticalScrollLengthRatio():Number;
	function addElement(element:IVisualElement):IVisualElement;
}

}