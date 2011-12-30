package cream.components.images
{
	import cream.components.FlexibleComponent;
	
	import mx.core.BitmapAsset;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.events.FlexEvent;

import spark.components.Image;

import spark.components.Image;

	public class Image extends FlexibleComponent
	{
		private var image:spark.components.Image;
		
        override protected function get visualElement():IVisualElement { return image; }
        override protected function get visualElementContainer():IVisualElementContainer { return null; }
        
		public function Image(asset:BitmapAsset = null)
		{
			super();

			if(asset)  {
				image.addEventListener(FlexEvent.CREATION_COMPLETE, function():void
				{
					image.source = asset;
					image.width = asset.width;
					image.height = asset.height;
				});
			}
		}
        
        override protected function initUnderlyingComponents():void
        {
            image = new spark.components.Image();
        }
	}
}