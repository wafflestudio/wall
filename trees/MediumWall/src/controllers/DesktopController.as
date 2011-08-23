package controllers
{
	import components.perspectives.IMultipleWallPerspective;
	import components.perspectives.IPerspective;
	import components.perspectives.TabbedPerspective;
	
	import flash.errors.IOError;
	import flash.filesystem.File;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Application;
	
	import storages.IXMLizable;
	import storages.history.IHistory;

	public class DesktopController extends FileStoredController implements IDesktopController
	{
		protected var history:IHistory;
		protected var perspective:IMultipleWallPerspective;
		
		public function DesktopController(configFile:File = null)
		{
			load(configFile);
		}
		
		override public function setup(app:IVisualElementContainer):void
		{
			perspective.addToApplication(app);
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
			trace(configXML);
			
			perspective = new TabbedPerspective();
			
			perspective.addCommitEventListener(function():void
			{
				saveAs();
			});
			
			perspective.fromXML(configXML.perspective[0]);
			
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
				<DesktopConfig/>;
					
			xml.appendChild(perspective.defaultXML);
			// TODO: other configuration values;
			
			return xml;
		}
	}
}