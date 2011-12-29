/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 11.
 * Time: 오후 8:25
 * To change this template use File | Settings | File Templates.
 */
package cream.eventing.events {
import cream.eventing.eventdispatchers.IEventDispatcher;

public class MessageEvent extends Event{

    public static const MESSAGE_RECEIVED:String = "message_received";

    protected var _message:Object;

    public function get message():Object
    {
        return _message;
    }

    public function MessageEvent(dispatcher:IEventDispatcher, message:Object)
    {
        super(dispatcher, MESSAGE_RECEIVED);
        this._message = message;
    }
}
}
