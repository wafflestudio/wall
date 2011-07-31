package storages
{
import flash.filesystem.File;

public interface IFileStorable
{
	function load(file:File = null):void;
	function saveAs(file:File = null):void;
}
}