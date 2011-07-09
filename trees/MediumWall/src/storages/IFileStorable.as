package storages
{
import flash.filesystem.File;

public interface IFileStorable
{
	function load(file:File = null):void;
	function save(file:File = null):void;
}
}