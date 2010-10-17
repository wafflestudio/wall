package model
{
	import mx.collections.ArrayCollection;

	public class UserData
	{
		public var identity:String;
		public var walls:ArrayCollection;
		
		public function UserData(xml:XML)  {
			if(xml)  {
				for each(var wallXML:XML in xml.children())  {				
					var wall:WallData = new WallData(wallXML);
					this.walls.addItem( wall );
				}
				this.identity = xml.@identity;
			}
		}
		
		public function toXML():XML  {
			var xml:XML = <user/>;
			xml.@identity = identity;
			
			for(var i:int = 0; i < walls.length; i++)  {
				var wallXML:XML = (walls[i] as WallData).toXML();
				xml.appendChild(wallXML);
			}
			
			return xml;	
		}
	}
}