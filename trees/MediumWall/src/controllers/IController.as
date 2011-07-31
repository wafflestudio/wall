package controllers
{
import mx.core.IVisualElementContainer;

import spark.components.Application;


public interface IController
{
	function load():void;
	function save():void;
	function setup(app:IVisualElementContainer):void;
}
}