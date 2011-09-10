package controllers
{
	import components.perspectives.TabbedPerspective;
	
	import eventing.events.CommitEvent;
	
	import flash.errors.IOError;
	import flash.filesystem.File;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Application;
	
	import storages.IXMLizable;
	import storages.history.History;

	public class DesktopController extends FileStoredController 
	{
		protected var history:History;
		protected var perspective:TabbedPerspective;
		
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
//			trace(configXML);
			
			perspective = new TabbedPerspective();
			
			perspective.fromXML(configXML.perspective[0]);
			
			perspective.addCommitEventListener(function(e:CommitEvent):void
			{
				trace("commited:" + e.actionName, e.args);
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