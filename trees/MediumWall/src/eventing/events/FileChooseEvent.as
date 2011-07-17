package eventing.events
{
import flash.filesystem.File;
import eventing.eventdispatchers.IEventDispatcher;

public class FileChooseEvent extends Event
{
	public static const FILE_CHOSE:String = "fileChose";
	private var _file:File;
	
	public function FileChooseEvent(dispatcher:IEventDispatcher, f:File)
	{
		super(dispatcher, FILE_CHOSE);
		_file = f;
	}
	
	public function get file():File
	{
		return _file;	
	}
}
}