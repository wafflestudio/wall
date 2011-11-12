package controllers
{
	import cream.components.dialogs.Dialog;
	import cream.components.dialogs.OpenWallDialog;
	import cream.components.perspectives.TabbedPerspective;
	import cream.components.sheets.Sheet;
	import cream.components.toolbars.CommandToolbar;
	import cream.components.walls.FileStoredWall;
	import cream.eventing.eventdispatchers.ICommitEventDispatcher;
	import cream.eventing.events.ActionCommitEvent;
	import cream.eventing.events.ClickEvent;
	import cream.eventing.events.ClipboardEvent;
	import cream.eventing.events.CommitEvent;
	import cream.storages.IXMLizable;
	import cream.storages.actions.Action;
	import cream.storages.actions.IActionCommitter;
	import cream.storages.clipboards.Clipboard;
	import cream.storages.history.History;
	import cream.utils.TemporaryFileStorage;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Application;

	public class DesktopController extends FileStoredController implements ICommitEventDispatcher
	{

		protected var history:History = new History();        // Undo/redo capability
		protected var perspective:TabbedPerspective;          // Root of Visual Elements
		protected var fileRef:FileReference;                  // Configuration file
		protected var clipboard:Clipboard = new Clipboard();  // Clipboard


		public function DesktopController(configFile:File = null)
		{
			load(configFile);
			
			var toolbar:CommandToolbar = perspective.toolbar;
			
			toolbar.newWallButton.addClickEventListener(
				function(e:ClickEvent):void {
					perspective.addWall(new FileStoredWall());
				}
			);
			
			toolbar.openWallButton.addClickEventListener(
				function(e:ClickEvent):void {
					var dialog:Dialog = new OpenWallDialog();
					dialog.show();
				}
			);
			
			
			toolbar.newImageSheetButton.addClickEventListener(
				function(e:ClickEvent):void {
					browseFileForNewImageSheet();
				}
			);
			
			toolbar.newSheetButton.addClickEventListener(
				function(e:ClickEvent):void {
					perspective.addTextSheet();					
				}
			);
			
			toolbar.undoButton.addClickEventListener(
				function(e:ClickEvent):void {
					var action:Action = history.rollback();
					if(action)  {
						disableHistory();
						action.committer.revertAction(action);
						trace("undo: " + action.type);
						enableHistory();
					}
				}
			);
			
			toolbar.redoButton.addClickEventListener(
				function(e:ClickEvent):void {
					var action:Action = history.playForward();
					if(action)  {
						disableHistory();
						action.committer.applyAction(action);
						trace("redo: " + action.type);
						enableHistory();
					}
				}
			);
			
			toolbar.saveAsButton.addClickEventListener(
				function(e:ClickEvent):void {
					trace(perspective.currentWall.name);
					perspective.currentWall.saveWallAs();
				}
			);
			
			toolbar.copyButton.addClickEventListener(
				function(e:ClickEvent):void {
					clipboard.copyTest();
				}
			);
			
			enableHistory();
			
		}
		
		override public function setup(app:IVisualElementContainer):void
		{
			perspective.addToApplication(app);
			
		}
		
		private function onCommit(e:CommitEvent):void
		{
			var actionEvent:ActionCommitEvent = e as ActionCommitEvent;
			trace((actionEvent ? "action committed " : "committed ") + e.actionName, e.args);
			
			if(actionEvent)
				history.writeForward(new Action(e.actionName, e.dispatcher as IActionCommitter, e.args));
		}
		
		
		protected function enableHistory():void
		{
			addCommitEventListener( onCommit );
		}
		
		protected function disableHistory():void
		{
			removeCommitEventListener( onCommit );
		}
		
		
		public function addCommitEventListener(listener:Function):void
		{
			addEventListener(CommitEvent.COMMIT, listener);
		}
		
		public function removeCommitEventListener(listener:Function):void
		{
			removeEventListener(CommitEvent.COMMIT, listener);	
		}
		
		protected function dispatchCommitEvent(e:CommitEvent):void
		{
			dispatchEvent(e);
		}
		
		
		private function browseFileForNewImageSheet():void
		{
			var imageFile:File = new File();
			imageFile.addEventListener(Event.SELECT, 
				function onSelect(e:Event):void  {
					var destFile:File = TemporaryFileStorage.imageAssetsResolve(imageFile.name);
					if(destFile.exists) {
						trace("file name already exists");
					} else {
						imageFile.copyTo(destFile);
					}
					
					var loader:Loader = new Loader();
					var fs:FileStream = new FileStream();
					var ba:ByteArray = new ByteArray();
					fs.open(e.target as File, FileMode.READ);
					fs.readBytes(ba, 0, ba.bytesAvailable);
					ba.position = 0;
					
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
						var bitmapData:BitmapData;
						bitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;
						perspective.addImageSheet(destFile, bitmapData.width, bitmapData.height);
					});
					loader.loadBytes(ba);
				}
			);
			imageFile.browse();
		}
	
		/**
		 * <DesktopConfig>
		 * 	<perspective>
		 * 		<walls>
		 * 			<wall file=""/>
		 * 		</walls>
		 * 	</perspective>
		 * </DesktopConfig>
		 */
		override public function fromXML(configXML:XML):IXMLizable
		{
//			trace(configXML);
			
			perspective = new TabbedPerspective();
			
			perspective.fromXML(configXML.perspective[0]);
			
			perspective.addCommitEventListener(function(e:CommitEvent):void
			{
				dispatchCommitEvent(e);
				saveAs();
			});
			
			return this;	
		}
		
		override public function toXML():XML
		{
			var xml:XML = <DesktopConfig/>;
			
			// TODO: other configuration values;
			
			xml.appendChild(perspective.toXML());
			
			return xml;
		}
		
		override public function get defaultXML():XML
		{
			var xml:XML = 
				<DesktopConfig>
					<perspective/>
				</DesktopConfig>
					
//			xml.appendChild(perspective.defaultXML);
			// TODO: other configuration values;
			
			return xml;
		}
	}
}