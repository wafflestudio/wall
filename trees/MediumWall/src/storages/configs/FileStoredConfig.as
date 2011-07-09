package storages.configs
{
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.filesystem.FileMode;
import flash.errors.IOError;
import flash.errors.EOFError;
import storages.sessions.ISession;
import utils.XMLFileStream;


public class FileStoredConfig extends Config implements IFileStoredConfig
{
	protected var defaultFile:File = File.applicationStorageDirectory.resolvePath(".config");
	
	
	public function FileStoredConfig()
	{
		super();
		session.addCommitEventListener( function():void
		{
			save();
		});
	}
	
	public function load(file:File = null):void
	{	
		file = file ? file : defaultFile;
		
		var reader:XMLFileStream = new XMLFileStream(file);
		try {
			fromXML(reader.getXML());
		}
		catch(e:IOError)
		{
			trace("unable to load file " + file.nativePath + ", using default");
			fromXML(defaultXML);
			save();
		}
	}
	
	public function save(file:File = null):void
	{
		if(file == null)
			file = defaultFile;
		
		
		var xml:XML = toXML();// any errors according to serialization must happen beforehand to opening the file
		var writer:XMLFileStream = new XMLFileStream(file);
		try {
			writer.setXML(xml);
		}
		catch(e:IOError)
		{
			throw new IOError("unable to save file" + file.nativePath);
		}
	}
}
}