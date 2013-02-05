class window.Chat
  users: {}

  constructor: (url) ->
    WS = if window['MozWebSocket'] then MozWebSocket else WebSocket
    @socket = new WS(url)
    @socket.onmessage = @onReceive
    @socket.onerror = @onError
    @socket.onclose = @onError
    @chatWindow = $('#chatWindow')
    @chatLog = $('#chatLog')
    @userList = $('#chatUsers')
    @chatInput = $('#chatInput')
    @chatInput.on 'keyup', (event) => @sendMessage() if event.keyCode is 13

  toggle: -> @chatWindow.fadeToggle()

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
      console.log data

      if data.error
        console.log('disconnected: ' + data.error)
        @socket.close()
        return
      
      newMessage = $("<div class = 'chatMessage'><p></p></div>")

      switch data.kind
        when "join"
          newMessage.children('p').text data.nickname + " has joined." unless @users[data.username]?
          @refreshUser(data.users)
        when "quit"
          newMessage.children('p').text @users[data.username].nickname + " has left." if @users[data.username].sessionCount is 1
          @refreshUser(data.users)
        when "talk" then newMessage.children('p').text @users[data.username].nickname + ": " + data.message

      @chatLog.append newMessage
      @chatLog.animate {scrollTop : @chatLog.prop('scrollHeight') - @chatLog.height()}, 200
  
  onError: (e) ->
    console.log(e)
  
  refreshUser: (data) ->
    @users = {}
    @userList.html('')
    @userJoin(user) for user in data
    @addUser(user) for email, user of @users

  userJoin: (user) ->
    user.sessionCount = 0
    @users[user.email] = user unless @users[user.email]?
    @users[user.email].sessionCount++

  addUser: (user) ->
    @userList.append $("<div class = 'chatProfilePic' style = 'background-image:url(#{user.picture})'> </div>")

  #userQuit: (user) ->
    #if users[user.email].sessionCount is 1
      #delete users[user.email]
    #else
      #users[user.email].sessionCount--
