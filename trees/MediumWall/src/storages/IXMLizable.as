package storages
{
public interface IXMLizable 
{
	function fromXML(xml:XML):IXMLizable;
	function toXML():XML;
}
}