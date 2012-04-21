package cream.components.walls
{
import cream.components.IFileStoredComponent;
import cream.eventing.events.ClipboardEvent;
import cream.eventing.events.CommitEvent;
import cream.eventing.events.Event;
import cream.storages.IFileReference;
import cream.storages.IFileStorable;
import cream.storages.INameable;
import cream.storages.IXMLizable;
import cream.utils.TemporaryFileStorage;
import cream.utils.XMLFileStream;

import flash.display.BitmapData;

import flash.events.Event;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.graphics.codec.PNGEncoder;

public class FileStoredWall extends Wall implements IFileStorable, IFileReference, IFileStoredComponent, INameable
{
	public static const EXTENSION:String = "wall";
	private var rootDirectory:File;
	
	
	public function FileStoredWall(file:File = null)
	{
		super();
		
		if(file)
			load(file);
		else  {
			rootDirectory = TemporaryFileStorage.resolve();
			saveAs();
		}
		
		addCommitEventListener( function(e:CommitEvent):void  {
			saveAs();
		});

        addPasteEventListener( function(e:ClipboardEvent):void
        {
            if(e.format == ClipboardEvent.TEXT_FORMAT) {
                addTextSheet(e.object as String);
            } else if(e.format == (ClipboardEvent.BITMAP_FORMAT)) {

                var imageFile:File = null;
                var encoder:PNGEncoder = new PNGEncoder();
                var bitmapData:BitmapData = e.object as BitmapData;
                var rawBytes:ByteArray = encoder.encode(bitmapData);
                imageFile = TemporaryFileStorage.imageAssetsResolve("png",File.applicationStorageDirectory.resolvePath(name));
                var fileStream:FileStream = new FileStream();
                fileStream.open( imageFile, FileMode.WRITE );
                fileStream.writeBytes( rawBytes );
                fileStream.close();
                addImageSheet(imageFile, bitmapData.width, bitmapData.height );
            }
        });
	}

    public function get relativePath():File {
        if(rootDirectory)
            return rootDirectory; // containing directory
        return null;
    }
	
	public function get file():File
	{
		return rootDirectory;
	}
	
	public function moveFile():void
	{
//		file.moveToAsync(
	}
	
	public function load(file:File = null):void
	{
		// prevent load after first load
		if(rootDirectory != null)
			throw new Error("cannot load already loaded object");
		
		rootDirectory = file ? file : rootDirectory;

		var fs:XMLFileStream = new XMLFileStream(file.resolvePath("index.wall"));

		
		// must read from Wall.fromXML 
		super.fromXML(fs.getXML());
	}
	
	public function saveAs(file:File = null):void
	{
		if(file == null)  {
			saveAs(rootDirectory);
			return;
		}
		
		var xml:XML = super.toXML(); // any errors according to serialization must happen beforehand to opening the file
		
		var fs:XMLFileStream = new XMLFileStream(rootDirectory.resolvePath("index.wall"));
		fs.setXML(xml);
	}

    public function saveAsDialog():void {
        var f:File = File.desktopDirectory;
        f.browseForSave("Save As");
        f.addEventListener(flash.events.Event.SELECT, function(e:flash.events.Event):void {
//			var xml:XML = wallXML; // any errors according to serialization must happen beforehand to opening the file
            //why toXML execute FileStoredWall's toXML?? T.T
            var targetDirectory:File = e.target as File;
//			var fs:XMLFileStream = new XMLFileStream(targetDirectory.resolvePath("index.wall"));
//			fs.setXML(xml);
            var sourceDirectory:File = File.applicationStorageDirectory.resolvePath(name);
            sourceDirectory.copyTo(targetDirectory,true);
        });
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
		xml.@file = rootDirectory.nativePath;
		return xml;
	}
}
}