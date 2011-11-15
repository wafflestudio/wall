package cream.utils
{
	import flash.system.Capabilities;

	public class Platform
	{
		public function Platform()
		{
			trace('access to the constructor for an unused object Platform');
		}
		
		public static function get isWindows():Boolean
		{
			return Capabilities.os.indexOf("Windows") >= 0;
		}
		
		public static function get isMac():Boolean
		{
			return Capabilities.os.indexOf("Mac") >= 0;
		}
		
		public static function get isLinux():Boolean
		{
			return Capabilities.os.indexOf("Linux") >= 0;
		}
			
	}
}