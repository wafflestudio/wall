package controllers
{
	import components.dialogs.Dialog;
	import components.dialogs.OpenWallDialog;
	import components.perspectives.TabbedPerspective;
	import components.sheets.Sheet;
	import components.toolbars.CommandToolbar;
	import components.walls.FileStoredWall;
	
	import eventing.eventdispatchers.ICommitEventDispatcher;
	import eventing.events.ActionCommitEvent;
	import eventing.events.ClickEvent;
	import eventing.events.CommitEvent;
	
	import flash.errors.IOError;
	import flash.filesystem.File;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Application;
	
	import storages.IXMLizable;
	import storages.actions.Action;
	import storages.actions.IActionCommitter;
	import storages.history.History;

	public class DesktopController extends FileStoredController implements ICommitEventDispatcher
	{
		protected var history:History = new History();
		protected var perspective:TabbedPerspective;
		
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
					perspective.addSheet(Sheet.IMAGE_SHEET);
				}
			);
			
			toolbar.newSheetButton.addClickEventListener(
				function(e:ClickEvent):void {
					perspective.addSheet(Sheet.TEXT_SHEET);
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