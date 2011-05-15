package components.elements
{
import mx.core.IVisualElement;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.errors.IOError;
import flash.errors.EOFError;
import flash.filesystem.FileStream;

public class FileStoredWall extends Wall
{
	private var file:File;
	
	public static function create(file:File):FileStoredWall
	{	
		var wall:FileStoredWall = new FileStoredWall(file);
		
		return wall;
	}
	
	public function FileStoredWall(file:File)
	{
		this.file = file;
		
		var fileStream:FileStream = new FileStream();
		var wallXML:XML;
		
		try {
			fileStream.open( file, FileMode.READ );
			var file_content:String = fileStream.readUTFBytes(fileStream.bytesAvailable)
			if(file_content)
				wallXML = new XML(file_content);
		}
		catch(e:IOError)  {
			throw IOError('unable to find file');
			
		}
		catch(e:EOFError)  {
			throw IOError('bad reading of stream');
		}
		
		if(wallXML == null)
			wallXML = Wall.defaultValue;
		
		init(wallXML);
	}
	
	
	public function save():void
	{
		var fileStream:FileStream = new FileStream();
		fileStream.open( file, FileMode.WRITE );
		fileStream.writeUTFBytes( toXML() );
		trace('saved at ' + file.nativePath);
	}
	
	
	
}
}