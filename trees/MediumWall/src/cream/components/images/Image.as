package cream.components.images
{
	import cream.components.FlexibleComponent;
	
	import mx.core.BitmapAsset;
	import mx.events.FlexEvent;
	
	import spark.components.Image;

	public class Image extends FlexibleComponent
	{
		private var image:spark.components.Image = new spark.components.Image();
		
		public function Image(asset:BitmapAsset = null)
		{
			visualElement = image;
			visualElementContainer = null;
			
			if(asset)  {
				image.addEventListener(FlexEvent.CREATION_COMPLETE, function():void
				{
					image.source = asset;
					image.width = asset.width;
					image.height = asset.height;
				});
			}
			
		}
	}
}