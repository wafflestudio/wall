class window.ChatSocket
  constructor: (url) ->
    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    @socket = new WS(url)
    @socket.onmessage = @onReceive
    @socket.onerror = @onError
    @socket.onclose = @onError
    @chatLog = $('#chatLog')
    @userList = $('#chatUsers')
    @chatInput = $('#chatInput')
    @chatInput.on 'keyup', => @sendMessage() if event.keyCode is 13

  sendMessage: =>
      msg = @chatInput.val()
      msg = msg.substr(0, msg.length - 1) if msg.charAt(msg.length - 1) is '\n'
      
      if msg.length is 0 or /^(\s)+$/.test(msg)
        @chatInput.val("")
        return
        
      @socket.send JSON.stringify({text: msg})
      @chatInput.val("")

  onReceive: (e) =>
      data = JSON.parse(e.data)

      if data.error
        console.log('disconnected: ' + data.error)
        @socket.close()
        return
      
      newMessage = $("<div class = 'chatMessage'><p></p></div>")

      switch data.kind
        when "join" then newMessage.children('p').text data.nickname + " " + data.message
        when "quit" then newMessage.children('p').text data.nickname + " " + data.message
        when "talk" then newMessage.children('p').text data.nickname + ": " + data.message

      @chatLog.append newMessage
      @chatLog.animate {scrollTop : @chatLog.prop('scrollHeight') - @chatLog.height()}, 200

      @userList.html('')
      $(data.users).each (index, user) =>
        console.log user
        @userList.append('<li>' + user.nickname + '</li>')
  
  onError: (e) ->
    console.log(e)
