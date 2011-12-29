/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 11.
 * Time: 오후 8:24
 * To change this template use File | Settings | File Templates.
 */
package cream.eventing.eventdispatchers {
public interface IMessageEventDispatcher {
    function addMessageReceivedEventDispatcher(listener:Function):void;
    function removeMessageReceivedEventDispatcher(listener:Function):void;
}
}
