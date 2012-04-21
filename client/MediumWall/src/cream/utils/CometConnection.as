/**
 * Created by IntelliJ IDEA.
 * User: kindone
 * Date: 11. 12. 11.
 * Time: 오후 6:52
 * To change this template use File | Settings | File Templates.
 */
package cream.utils {
import cream.eventing.eventdispatchers.EventDispatcher;
import cream.eventing.eventdispatchers.IMessageEventDispatcher;
import cream.eventing.events.MessageEvent;

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

public class CometConnection extends EventDispatcher implements IMessageEventDispatcher {
    
    private var roomId:int = 0;
    private var timestamp:int = 0;
    
    public function CometConnection(roomId:int, timestamp:int) {
        this.roomId = roomId;
        this.timestamp = timestamp;
        longPoll();
    }

    public function send(text:String):void
    {
        var httpService:HTTPService = new HTTPService();
        httpService.url
                = "http://localhost:9000/Chat/sendChat?roomId=" + roomId + "&text=" + text;
        httpService.method = "GET";
        httpService.addEventListener("result", sendChatResult);
        httpService.addEventListener("fault", httpFault);
        httpService.send();
    }

    public function addMessageReceivedEventDispatcher(listener:Function):void
    {
        addEventListener(MessageEvent.MESSAGE_RECEIVED, listener);
    }

    public function removeMessageReceivedEventDispatcher(listener:Function):void
    {
        removeEventListener(MessageEvent.MESSAGE_RECEIVED, listener);
    }

    protected function longPoll():void
    {
        var httpService:HTTPService = new HTTPService();
        httpService.url = "http://localhost:9000/Chat/getUpdates?roomId=" + roomId + "&timestamp=" + timestamp;
        httpService.method = "GET";
        httpService.addEventListener("result", getUpdatesResult);
        httpService.addEventListener("fault", httpFault);
        httpService.send();
    }

    protected function sendChatResult(event:ResultEvent):void {

        var data = event.result as String;
        trace(data);

    }

    protected function getUpdatesResult(event:ResultEvent):void {

        var data = JSON.parse(event.result as String);
        trace(data);
        if(data!=null && data.length > 0)  {
            timestamp = data[data.length-1].timestamp;
            dispatchEvent(new MessageEvent(this, data));
        }

        longPoll();
    }

    protected function httpFault(event:FaultEvent):void {
        var faultstring:String = event.fault.faultString;
        trace('error in http');
    }
}
}
