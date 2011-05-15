package com.wafflestudio.wall.components.views
{
import spark.components.BorderContainer;
import mx.controls.Image;
import spark.components.HGroup;

public class CommandToolBar extends HGroup
{
	public function CommandToolBar()
	{
		this.height = 48 + 16;
		this.percentWidth = 100;
//		this.alpha = 0.8;
		
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		
		var bg:BorderContainer = new BorderContainer();
		bg.percentHeight = 100;
		bg.percentWidth = 100;
		bg.setStyle("backgroundColor", 0xffffff);
		bg.setStyle("borderAlpha",0);
		this.addElement(bg);
		
		var hgroup:HGroup = new HGroup();
		hgroup.percentHeight = hgroup.percentWidth = 100;
		bg.addElement(hgroup);
		
		var openbtn:Image = new Image();
		var addbtn:Image = new Image();
		var savebtn:Image = new Image(); 
		
		
		addbtn.load("plus.png");
		hgroup.addElement(addbtn);
		savebtn.load("save.png");
		hgroup.addElement(savebtn);
		
		
		

	}
}
}