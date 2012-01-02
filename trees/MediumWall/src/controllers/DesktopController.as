package controllers
{
import cream.components.dialogs.AlertDialog;
import cream.components.dialogs.ChatDialog;
import cream.components.perspectives.TabbedPerspective;
	import cream.components.toolbars.CommandToolbar;
	import cream.components.walls.FileStoredWall;
import cream.components.walls.SynchronizableWall;
import cream.eventing.eventdispatchers.ICommitEventDispatcher;
	import cream.eventing.events.ActionCommitEvent;
	import cream.eventing.events.ClickEvent;
	import cream.eventing.events.CommitEvent;
	import cream.storages.IXMLizable;
	import cream.storages.actions.Action;
	import cream.storages.actions.IActionCommitter;
	import cream.storages.clipboards.Clipboard;
	import cream.storages.history.History;
    import cream.utils.CometConnection;
    import cream.utils.Platform;
	import cream.utils.TemporaryFileStorage;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElementContainer;


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

            toolbar.newRemoteWallButton.addClickEventListener(
                function(e:ClickEvent):void {
                    perspective.addWall(new SynchronizableWall());
                }
            );

            toolbar.openWallButton.addClickEventListener(
				function(e:ClickEvent):void {
//					var dialog:OpenWallDialog = new OpenWallDialog();
//					dialog.show();
//					dialog.addFileChoseEventListener(function(e:flash.events.Event):void {
//						perspective.addWall(new FileStoredWall(e.target as File));
//
//					});
					var f:File = File.desktopDirectory;
					f.browseForOpen("Open wall");
					f.addEventListener(flash.events.Event.SELECT, function(e:flash.events.Event):void { 
						perspective.addWall(new FileStoredWall(e.target as File));
					});
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
			
			toolbar.undoButton.addClickEventListener( function(e:ClickEvent):void { onUndo() } );
			
			toolbar.redoButton.addClickEventListener( function(e:ClickEvent):void { onRedo() } );
				
			
			toolbar.saveAsButton.addClickEventListener(
				function(e:ClickEvent):void {
					perspective.currentWall.saveWallAs();
				}
			);
            

			
            // test
            toolbar.testButton.addClickEventListener(
                function(e:ClickEvent):void {
                    var dialog:ChatDialog = new ChatDialog();
					dialog.show();
                }
            );
            
            
			FlexGlobals.topLevelApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, function (e:KeyboardEvent):void
			{
				
				// ctrl-z // command-z
				if(((Platform.isWindows && e.ctrlKey) && (e.keyCode == 90 || e.keyCode == 122)) ||
					(Platform.isMac && e.commandKey && !e.shiftKey && (e.keyCode == 90 || e.keyCode == 122)))
				{
					onUndo();
				}
				// ctrl-y // command-shift-z
				else if((Platform.isWindows && e.ctrlKey && (e.keyCode == 89 || e.keyCode == 121)) ||
					(Platform.isMac && e.commandKey && e.shiftKey && (e.keyCode == 90 || e.keyCode == 122)) )
				{
					onRedo();
				}

			});
			

			
			enableHistory();
			
		}
		
		override public function setup(app:IVisualElementContainer):void
		{
			perspective.addToApplication(app);
			
		}
		
		private function onUndo():void
		{
			var action:Action = history.rollback();
			if(action)  {
				disableHistory();
				action.committer.revertAction(action);
				trace("undo: " + action.type);
				enableHistory();
			}
		}
		
		private function onRedo():void
		{
			var action:Action = history.playForward();
			if(action)  {
				disableHistory();
				action.committer.applyAction(action);
				trace("redo: " + action.type);
				enableHistory();
			}
		
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
					var destFile:File = TemporaryFileStorage.imageAssetsResolve(imageFile.extension,File.applicationStorageDirectory.resolvePath(perspective.currentWall.name),imageFile.name);
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