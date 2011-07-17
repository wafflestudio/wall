package components.walls
{
import flash.filesystem.File;
import utils.XMLFileStream;
import utils.TemporaryFileStorage;
import storages.IXMLizable;
import components.sheets.ISheet;
import eventing.events.Event;

public class FileStoredWall extends Wall implements IFileStoredWall
{
	private var _file:File;
	
	public function FileStoredWall(file:File = null)
	{
		super();
		
		if(file != null)
			load(file);
		else  {
			_file = TemporaryFileStorage.resolve();
			save();
		}
		
		addCommitEventListener( function(e:Event):void  {
			save();
		});
	}
	
	public function get file():File
	{
		return new File();
	}
	
	public function moveFile():void
	{
		
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
	
	public function save(file:File = null):void
	{
		if(file == null)
			save(_file);
		
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