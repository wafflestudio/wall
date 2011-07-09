package controllers
{
import spark.components.Application;

public interface IController
{
	function load():void;
	function save():void;
	function setup(app:Application):void;
}
}