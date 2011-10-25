package cream.utils
{
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.filesystem.FileMode;
import flash.errors.IOError;
import flash.errors.EOFError;
import spark.components.BorderContainer;

public class XMLFileStream 
{
	private var file:File;
	
	public function XMLFileStream(file:File)
	{
		this.file = file;	
	}
	
	public function setXML(xml:XML):void
	{
		var fileStream:FileStream = new FileStream();
		
		try {
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeUTFBytes( xml );
			trace('saved ' + file.nativePath);
			// fs.close is not needed??
		}
		catch(e:IOError)  {
			trace('IOError:' + e.name + ":" + e.message);
		}
		catch(e:EOFError)  {
			trace('EOFError' + e.name + ":" + e.message);
		}
	}
	
	public function getXML():XML
	{
		var xml:XML;
		
		try {		
			var fileStream:FileStream = new FileStream();	
			fileStream.open( file, FileMode.READ );
			var fileContent:String = fileStream.readUTFBytes(fileStream.bytesAvailable)
			if(fileContent)  {
				xml = new XML(fileContent);
				if(xml == null)
					throw new IOError("bad xml");
			}	
		}
		catch(e:IOError)  {
			trace('IOError:' + e.name + ":" + e.message);
			throw new IOError("unable to load file" + file.nativePath);
		}
		catch(e:EOFError)  {
			trace('EOFError' + e.name + ":" + e.message);
			throw new IOError("unable to load file" + file.nativePath);
		}
		
		
		
		return xml;	
	}
}
}