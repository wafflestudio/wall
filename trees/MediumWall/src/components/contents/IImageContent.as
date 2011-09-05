package components.contents
{
	import flash.display.BitmapData;

	public interface IImageContent extends IContent
	{
		function getBitmapData():BitmapData;
	}
}