package cream.utils
{
import flash.errors.IllegalOperationError;
import flash.filesystem.File;
import flash.globalization.StringTools;

import mx.utils.StringUtil;

public class TemporaryFileStorage
{
	public function TemporaryFileStorage()
	{
		throw new IllegalOperationError("Access to a singleton constructor");
	}
	
	public static function resolve(extension:String, targetDirectory:File = null, targetFileName:String = null):File
	{
		if(!targetDirectory)
			targetDirectory = File.applicationStorageDirectory;
		var file:File = null;
		if(targetFileName) {
			file = targetDirectory.resolvePath(targetFileName+"."+extension);
			if(file.exists)
				trace("wall name conflict");
		} else {
			file = setUnnamedFile(extension, targetDirectory);
		}
		
		return file;
	}

	public static function imageAssetsResolve(extension:String, targetDirectory:File = null, imageFileName:String = null):File
	{
		var _targetDirectory:File = null;
		if(!targetDirectory)
			_targetDirectory = File.applicationStorageDirectory.resolvePath("assets/images");
		else
			_targetDirectory = targetDirectory.resolvePath("assets/images");
		
		var file:File = null;
		if(imageFileName) {
			file = _targetDirectory.resolvePath(imageFileName+"."+extension);
			if(file.exists)
				trace("wall name conflict");
			
		} else {
			file = setUnnamedFile(extension, _targetDirectory);
		}
		return file;
	}
	
	private static function setUnnamedFile(extension:String, targetDirectory:File):File {
		var contents:Array = null;
		var num:int = 0;
		if(targetDirectory.exists) {
			contents = targetDirectory.getDirectoryListing();
			for (var i:uint = 0; i < contents.length; i++) 
			{
				var name:String = contents[i].name as String;
				var matches:Array = name.match(new RegExp("\bunnamed[0-9]{5}\." + extension + "\b/"));
				if(matches == null || matches.length != 1)
					continue;
				
				var n:int = parseInt(name.replace(new RegExp("/\bunnamed([0-9]{5})\." + extension + "\b/"), "$1"), 10);
				num = n > num ? n : num;	
			}
		} else {
			num = 1;
		}

		var _file:File = null;
		while(true) {
			num ++;
			var newName:String = "0000" + num;
			newName = "unnamed" + newName.substr(newName.length-5, 5) + "." + extension; // "000011" => "00011"
			//TODO get current wall's name
			_file = targetDirectory.resolvePath(newName);
			if(!_file.exists) 
				break;
			
			trace("file(" + newName + ") already exists, skipping");
		}
		
		return _file;
	}
	
}
}