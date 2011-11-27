package controllers
{
	import cream.eventing.eventdispatchers.EventDispatcher;
	import cream.storages.IXMLizable;
	import cream.utils.XMLFileStream;
	
	import flash.errors.EOFError;
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.core.IVisualElementContainer;
	
	
	public class FileStoredController extends EventDispatcher implements IXMLizable
	{
		protected var defaultFile:File = File.applicationStorageDirectory.resolvePath(".config");
		
		
		public function FileStoredController()
		{
			super();
			
		}
		
		protected function load(file:File = null):void
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
				saveAs();
				
			}
		}
		
		protected function saveAs(file:File = null):void
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
		
		
		public function fromXML(configXML:XML):IXMLizable
		{
			throw new Error("this method should've been overrided!");
			return null;
		}
		
		public function toXML():XML
		{
			throw new Error("this method should've been overrided!");
			return null;	
		}
		
		public function get defaultXML():XML
		{
			throw new Error("this method should've been overrided!");
			return null;
		}
		
		
		public function setup(app:IVisualElementContainer):void
		{
			throw new Error("this method should've been overrided!");
		}
		
		
	}
}