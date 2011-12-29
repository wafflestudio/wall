package resources
{
	
	public class Assets
	{
		/** ### Place assets here **/
		[Embed(source="/resources/close.png")]
		[Bindable]
		public static var close_png:Class;
		
		[Embed(source="/resources/close_small.png")]
		[Bindable]
		public static var close_small_png:Class;
		
		/** ### Unused constructor **/
		public function Assets()
		{
		}
	}
}