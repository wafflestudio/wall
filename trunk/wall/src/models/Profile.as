package models
{
/** Plans:
 * 
 * Database:  Profile -> All basic configurations, UserInfo, Configurations
 * Files: Walls(XML) -> Sheets(XML) -> Contents(HTML)
 *  
 * **/
public class Profile
{
	public var preferedContentPath:String;
	public var username:String;
	
	public function Profile(xml:XML)
	{
		for each(var configXML:XML in xml.children())  {			
			
		}
		
	}
}
}