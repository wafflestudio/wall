package model  {
import mx.collections.ArrayCollection;
	
public class WallData
{
	public var width:Number;
	public var height:Number;
	public var sheets:ArrayCollection = new ArrayCollection([]);
	
	public function WallData(xml:XML)  {
	
		for each(var sheetXML:XML in xml.children())  {				
			var sheetdata:SheetData = new SheetData(sheetXML);
			this.sheets.addItem( sheetdata );
		}
		this.width = xml.@width;
		this.height = xml.@height;
		
	}
	
	public function toXML():XML  {
		var xml:XML = <wall/>;
		
		xml.@width = width;
		xml.@height = height;
		
		for(var i:int = 0; i < sheets.length; i++)  {
			var sheetXML:XML = (sheets[i] as SheetData).toXML();
			xml.appendChild(sheetXML);
		}		
		return xml;	
	}
	
}
}