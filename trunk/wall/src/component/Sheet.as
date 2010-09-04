package component
{
	import spark.components.BorderContainer;
	
	import utils.IDraggable;

	public class Sheet extends BorderContainer implements IDraggable
	{
		include "../utils/FDrag.as"
		
		public function Sheet()
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, dragStart);
		}
		
	}
}