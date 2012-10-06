class ChatSocket
  constructor: (url) ->
    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    socket = new WS(url)

    sendMessage = ()=>      
      msg = $('#talk').val()
      
      if msg.charAt(msg.length-1) == '\n'
        msg = msg.substr(0,msg.length-1)
        
      
      if msg.length == 0 or /^(\s)+$/.test(msg)
        $('#talk').val("")
        return
        
      socket.send JSON.stringify({text: msg})
      $('#talk').val("")

    onReceive = (e) ->
      data = JSON.parse(e.data);
      if data.error
        console.log('disconnected: ' + data.error)
        socket.close()
        return
      
      newMessage = $("<div class = 'chatMessage'><p></p></div>")
      newMessage.children('p').text data.username + " : " + data.message
      log = $("#log")

      log.append newMessage
      log.animate {scrollTop : log.prop('scrollHeight') - log.height()}, 200

      #$("#log").append("<p>" + data.username + " : " + data.message + "</p>")
      
      #update user list
      $('#users').html('')
      $(data.users).each () ->
        $('#users').append('<li>'+this+'</li>')
  
    onError = (e) ->
      console.log(e)
  
    socket.onmessage = onReceive
    socket.onerror = onError
    socket.onclose = onError

    # initialize on startup
    $( ()=>
      $('#talk').keyup (event) =>
        if event.keyCode == 13
          sendMessage()
    )

window.ChatSocket = ChatSocket
