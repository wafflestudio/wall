package components.dialogs
{
import eventing.eventdispatchers.IFileChooseEventDispatcher;
import eventing.events.FileChooseEvent;

import flash.events.MouseEvent;
import flash.filesystem.File;

import mx.binding.utils.BindingUtils;
import mx.controls.FileSystemComboBox;
import mx.controls.FileSystemDataGrid;
import mx.events.FileEvent;

import spark.components.Button;
import spark.components.HGroup;
import spark.components.VGroup;

public class FileChooseDialog extends Dialog implements IFileChooseEventDispatcher
{
	public function FileChooseDialog()
	{
		super();
		tw.width = 600;
		tw.height = 600;
		title = "Select file";
		
		var vg:VGroup = new VGroup();
		vg.percentWidth = 100;
		vg.percentHeight = 100;
		tw.addElement(vg);
		
		var fc:FileSystemComboBox = new FileSystemComboBox();
		fc.percentWidth = 100;
		fc.directory = File.documentsDirectory;
		vg.addElement(fc);
		
		
		var fg:FileSystemDataGrid = new FileSystemDataGrid();
		fg.directory = File.documentsDirectory;
		fg.percentWidth = 100;
		fg.percentHeight = 100;
		fg.extensions = [".wall"];
		vg.addElement(fg);
		
		BindingUtils.bindProperty(fg, "directory", fc, "directory");
		BindingUtils.bindProperty(fc, "directory", fg, "directory");
		
		var hg:HGroup = new HGroup();
		hg.percentWidth = 100;
		hg.height = 30;
		hg.horizontalAlign = "center";
		vg.addElement(hg);
		
		var ok:Button = new Button();
		ok.label = "Accept";
		hg.addElement(ok);
		
		ok.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
			dispatchEvent(new FileChooseEvent(this, new File(fg.selectedPath)));
			close();
		});
		
		var cancel:Button = new Button();
		cancel.label = "Cancel";
		hg.addElement(cancel);
		
		cancel.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
			dispatchCancelEvent();
			close();
		});
		
	}
	
	public function addFileChoseEventListener(listener:Function):void
	{
		addEventListener(FileChooseEvent.FILE_CHOSE, listener);	
	}
	
	public function removeFileChoseEventListener(listener:Function):void
	{
		removeEventListener(FileChooseEvent.FILE_CHOSE, listener);
	}
	
	
}
}