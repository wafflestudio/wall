
function WallSocket(url) {
	$.extend(this, new this.$super());

	var timestamp = 999
	var WS = window['MozWebSocket'] ? MozWebSocket : WebSocket
	var socket = new WS(url)
	var self = this;

	function send(msg) {
		socket.send(JSON.stringify(msg))
	}

	function onReceive(e) {

		var data = JSON.parse(e.data);
		
		if(data.error) {
			console.log('disconnected: ' + data.error)
			socket.close();
			return;
		}
		
		if(data.kind == "action" && timestamp < data.timestamp)  {
			var detail = JSON.parse(data.detail)
			self.trigger('receive', detail)
			timestamp = data.timestamp;
			
		}
	}

	function onError(e) {
		console.log("error", e);
		self.trigger('error', e)
	}

	function onClose(e) {
		console.log("close", e)
		self.trigger('close', e)
	}


	socket.onmessage = onReceive
	socket.onerror = onError
	socket.onclose = onClose
	this.send = send
	this.socket = socket
	this.close = socket.close
}

WallSocket.prototype.$super = EventDispatcher;
