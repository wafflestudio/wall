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
	
	public static function resolve():File
	{
		var directory:File = File.applicationStorageDirectory;
		var contents:Array = directory.getDirectoryListing();
		var num:int = 0;
		for (var i:uint = 0; i < contents.length; i++) 
		{
			var name:String = contents[i].name as String;
			var matches:Array = name.match(/\bunnamed[0-9]{5}\.wall\b/);
			if(matches == null || matches.length != 1)
				continue;
			
			var n:int = parseInt(name.replace(/\bunnamed([0-9]{5})\.wall\b/, "$1"), 10);
			num = n > num ? n : num;	
		}
		
		var file:File = null;
		
		while(true) {
			num ++;
			var newName:String = "0000" + num;
			newName = "unnamed" + newName.substr(newName.length-5, 5) + ".wall"; // "000011" => "00011"
			
			file = File.applicationStorageDirectory.resolvePath(newName);
			if(!file.exists) 
				break;
			
			trace("file(" + newName + ") already exists, skipping");
		}
		
		return file;
	}
	
	public static function imageAssetsResolve(name:String):File
	{
		var file:File = null;
		file = File.applicationStorageDirectory.resolvePath("assets/images/"+name);
		if(!file.exists) 
			trace("name conflict");
		
		return file;
	}
	
	
	
	
}
}