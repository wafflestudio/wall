package com.wafflestudio.wall.components.views
{
import spark.components.BorderContainer;
import spark.components.VGroup;
import spark.components.TabBar;
import mx.containers.ViewStack;
import mx.core.IVisualElement;
import spark.components.Group;
import com.wafflestudio.wall.components.elements.Wall;
import spark.components.NavigatorContent;
import com.wafflestudio.wall.components.elements.FileStoredWall;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.filesystem.FileMode;
import flash.errors.IOError;
import flash.errors.EOFError;


// MainView
//	
public class MainView extends Group
{

	public function MainView(sessionXML:XML)
	{
		viewStack = new ViewStack();
		viewStack.percentHeight = viewStack.percentWidth = 100;
	}
	
	public function addBlankSheetToCurrentWall():void
	{
		var wall:Wall = viewStack.getElementAt(viewStack.numElements-1) as Wall;
		wall.addNewBlankSheet();
	}
	
	public function getCurrentWallXML():XML
	{
		var wallFile:FileStoredWall = viewStack.getElementAt(viewStack.numElements-1) as FileStoredWall;
		return wallFile.toXML();
	}
	
	public function toXML():XML
	{
		var sessionXML:XML = <session/>;
		var openWallsXML:XML = <openWalls/>;
		
		for each(var wall:FileStoredWall in walls)  {
			openWallsXML.appendChild(wall.toXML());			
		}
		
		sessionXML.appendChild(openWallsXML);
		
		return sessionXML;
	}
	
	
	override public function initialize():void
	{
		super.initialize();
		this.percentHeight = this.percentWidth = 100;
	}
	
	private var viewStack:ViewStack;
	
	override protected function createChildren():void  {
		super.createChildren();
		
		var vgroup:VGroup = new VGroup();
		vgroup.percentHeight = vgroup.percentWidth = 100;
		vgroup.gap = 0;
		this.addElement(vgroup);
		
		var toolbar:CommandToolBar = new CommandToolBar();
		vgroup.addElement(toolbar);
		
		var tabbar:TabBar = new TabBar();
		tabbar.dataProvider = viewStack;
		vgroup.addElement(tabbar);
		vgroup.addElement(viewStack);	
	}
	
	public function addWall(file:File):void  {
		var nc:NavigatorContent = new NavigatorContent();
		nc.label = "Initial";
		nc.percentHeight = nc.percentWidth = 100;
		
		viewStack.addElement(nc);
		
		var group:Group = new Group();
		group.percentHeight = group.percentWidth = 100;
		group.clipAndEnableScrolling = true;
		nc.addElement(group);
		
		var wall:FileStoredWall = FileStoredWall.create(file);
		group.addElement(wall);
	}
	
	private function get walls():Array
	{
		var arr:Array = [];
		for(var i:int = 0; i < viewStack.numElements; i++)  {
			var nc:NavigatorContent = viewStack.getElementAt(0) as NavigatorContent;
			var group:Group = nc.getElementAt(0) as Group;
			var wall:FileStoredWall = group.getElementAt(0) as FileStoredWall;
			arr.push(wall);
		}	
		
		return arr;
	}
	
	public static function get defaultXML():XML
	{
		var sessionXML:XML =
			<session>
				<openWalls/>
			</session>;
		return sessionXML;
	}
	
}
}