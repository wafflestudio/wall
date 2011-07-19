package components.contents
{
	import components.Component;
	
	import eventing.events.CommitEvent;
	
	import storages.IXMLizable;
	
	public class Content extends Component implements IContent
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
		
		protected function dispatchCommitEvent():void
		{
			dispatchEvent(new CommitEvent(this));	
		}
	}
}