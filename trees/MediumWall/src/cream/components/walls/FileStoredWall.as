package cream.components.walls
{
import cream.eventing.events.CommitEvent;
import cream.eventing.events.Event;
import cream.storages.IFileStorable;
import cream.storages.INameableFileReference;
import cream.storages.IXMLizable;
import cream.utils.TemporaryFileStorage;
import cream.utils.XMLFileStream;

import flash.filesystem.File;

public class FileStoredWall extends Wall implements IFileStorable, INameableFileReference
{
	public static const EXTENSION:String = "wall";
	private var _file:File;
	
	
	public function FileStoredWall(file:File = null)
	{
		super();
		
		if(file != null)
			load(file);
		else  {
			_file = TemporaryFileStorage.resolve(EXTENSION,File.applicationStorageDirectory.resolvePath(this.name),"index");
			saveAs();
		}
		
		addCommitEventListener( function(e:CommitEvent):void  {
			saveAs();
		});
	}
	
	public function get file():File
	{
		return _file;
	}
	
	public function moveFile():void
	{
//		file.moveToAsync(
	}
	
	public function load(file:File = null):void
	{
		// prevent load after first load
		if(_file != null)
			throw new Error("cannot load already loaded object");
		
		_file = file ? file : _file;
		var fs:XMLFileStream = new XMLFileStream(file);
		
		// must read from Wall.fromXML 
		super.fromXML(fs.getXML());
	}
	
	public function saveAs(file:File = null):void
	{
		if(file == null)  {
			saveAs(_file);
			return;
		}
		
		var xml:XML = super.toXML(); // any errors according to serialization must happen beforehand to opening the file
		
		var fs:XMLFileStream = new XMLFileStream(_file);
		fs.setXML(xml);
	}
	
	/**
	 * 	<wall>
	 * 		<sheets>
	 * 			<sheet></sheet>
	 * 		</sheets>
	 * 	</wall>
	 */
	override public function fromXML(xml:XML):IXMLizable
	{	
		if(xml.@file)
			load(new File(xml.@file));
		else
			super.fromXML(xml);
		
		return this;
	}
	
	
	override public function toXML():XML
	{
		var xml:XML = <wall/>;
		xml.@file = _file.nativePath;
		return xml;
	}
}
}