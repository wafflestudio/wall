package model  {
	
public class SheetData
{
	public var x:Number;
	public var y:Number;
	public var width:Number;
	public var height:Number;
	
	public function SheetData(xml:XML)  {
			
		this.x = xml.@x;
		this.y = xml.@y;
		this.width = xml.@width;
		this.height = xml.@height;
		
		
	}
	
	public function toXML():XML  {
		var xml:XML = <sheet/>;
		
		xml.@x = this.x;
		xml.@y = this.y;
		xml.@width = this.width;
		xml.@height = this.height;
		
		return xml;	
	}
}
}