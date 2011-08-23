package controllers
{
import flash.filesystem.File;

import mx.core.IVisualElementContainer;

import spark.components.Application;

import storages.IXMLizable;


public interface IController extends IXMLizable
{
	function setup(app:IVisualElementContainer):void;
}
}