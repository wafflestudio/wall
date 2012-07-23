
function WallSocket(url) {

	var timestamp = 999
	var WS = window['MozWebSocket'] ? MozWebSocket : WebSocket
	var socket = new WS(url)

	function send(msg) {
		console.log("send")
		socket.send(JSON.stringify(msg))
	}

	function onReceive(e) {
		var data = JSON.parse(e.data);
		if(data.error) {
			console.log('disconnected: ' + data.error)
			socket.close();
			return;
		}
		console.log(data)
		if(data.kind == "action" && timestamp < data.timestamp)  {
				var detail = JSON.parse(data.detail)
				if(detail.action == "create")
					createSheet(detail.id, detail.params);
				else if(detail.action == "move")
					moveSheet(detail.params);
				else if(detail.action == "resize")
					resizeSheet(detail.params);
				else if(detail.action == "remove")
					removeSheet(detail.params);

				timestamp = data.timestamp;
			
		}
		$("#log").prepend("<p>" + "<span>" + data.username + "</span>" + "<span> " + data.message + "</span>" + "</p>")

	}

	function onError(e) {
		console.log(e);
	}

	socket.onmessage = onReceive
	socket.onerror = onError
	socket.onclose = onError

	this.socket = socket
	this.send = send
}

