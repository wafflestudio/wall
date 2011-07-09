package storages
{
import flash.filesystem.File;

public interface IFileRefence
{
	function get file():File;
	function moveFile():void;
}
}