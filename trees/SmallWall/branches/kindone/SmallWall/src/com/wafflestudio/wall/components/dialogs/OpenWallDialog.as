package com.wafflestudio.wall.components.dialogs
{
import flash.filesystem.File;

import mx.binding.utils.BindingUtils;
import mx.controls.Alert;
import mx.controls.FileSystemTree;
import mx.controls.Text;
import mx.events.FileEvent;
import mx.events.ListEvent;

import spark.components.Button;
import spark.components.HGroup;
import spark.components.TitleWindow;
import spark.components.VGroup;
import flash.events.MouseEvent;
import mx.events.CloseEvent;
import com.wafflestudio.wall.events.FormEvent;

[Event(name="xmlChange", type="com.wafflestudio.wall.events.FormEvent")]
public class OpenWallDialog extends TitleWindow
{
	public function OpenWallDialog()
	{
		this.title = "Open Wall";
	}
	
	private var text:Text;
	
	public function set wallPath(value:String):void  {
		text.text = value;
	}
	
	override public function initialize():void
	{
		super.initialize();
		var vg:VGroup = new VGroup();
		
		var fst:FileSystemTree = new FileSystemTree();
		fst.directory = File.userDirectory;
		fst.filterFunction = function (f:File):Boolean {
			return f.isDirectory;
		};
		fst.percentWidth = 100;
		
		text = new Text();
		text.text = File.userDirectory.nativePath;
		
		fst.addEventListener(ListEvent.CHANGE, function(e:ListEvent):void  {
			text.text = fst.selectedPath;
		});
		
		var btngrp:HGroup = new HGroup();
		var btnApply:Button = new Button();
		btnApply.label = "Apply";
		btnApply.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
			dispatchEvent(new FormEvent(FormEvent.CHANGE, false, false, <root><selectedPath value={text.text}/></root>));
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		});
		var btnCancel:Button = new Button();
		btnCancel.label = "Cancel";
		btnCancel.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		});
		
		btngrp.addElement(btnApply);
		btngrp.addElement(btnCancel);
		
		vg.percentHeight = vg.percentWidth = 100;
		vg.addElement(fst);
		vg.addElement(text);
		vg.addElement(btngrp);
		this.addElement(vg);
		
		this.width = 300;
		this.height = 400;
	}
}
}