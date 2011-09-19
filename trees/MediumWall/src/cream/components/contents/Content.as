package cream.components.contents
{
	import cream.components.Component;
	import cream.components.ICommitableComponent;
	
	import eventing.eventdispatchers.IEventDispatcher;
	import eventing.events.CommitEvent;
	
	import storages.IXMLizable;
	
	public class Content extends Component implements IXMLizable, ICommitableComponent
	{
		public function Content()
		{
			super();
			
		}
		
		
		public function fromXML(xml:XML):IXMLizable
		{
			return this;
		}
		
		/**
		 * 	<content>
		 * 		...
		 * 	</content>
		 */ 
		
		public function toXML():XML
		{
			var xml:XML = <content/>;
			return xml;
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
	}
}