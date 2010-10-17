// ActionScript file

public function scrollInit():void
{
	if(!this.hasEventListener(MouseEvent.MOUSE_DOWN))
		this.addEventListener(MouseEvent.MOUSE_DOWN, scrollStart);
}
