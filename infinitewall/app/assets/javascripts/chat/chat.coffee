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
      
      switch data.kind
        when "join"
          newMessage = @infoMaker(data.nickname, "has joined") unless @users[data.username]?
          @refreshUser(data.users)
        when "quit"
          newMessage = @infoMaker(@users[data.username].nickname, " has left") if @users[data.username].sessionCount is 1
          @refreshUser(data.users)
        when "talk" then newMessage = @messageMaker(@users[data.username], data.message)
        
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

  messageMaker: (user, message) ->
    owner = if user.email is stage.currentUser then "isMine" else "isNotMine"
    $("<div class = 'messageContainer'>
        <div class = 'messageDiv #{owner}'>
          <div class = 'messageProfilePicContainer'>
            <div class = 'messageProfilePic' style = 'background-image:url(#{user.picture})'></div>
          </div>
          <div class = 'messageRest'>
            <div class = 'messageNickname'>#{user.nickname}</div>
            <div class = 'messageText'>#{message}</div>
          </div>
        </div>
      </div>")

  infoMaker: (who, message) ->
    $("<div class = 'infoContainer'>
        <div class = 'infoMessage'>
          <span class = 'infoWho'>#{who}</span>
          <span class = 'infoMessage'>#{message}</span>
        </div>
      </div>")

  #userQuit: (user) ->
    #if users[user.email].sessionCount is 1
      #delete users[user.email]
    #else
      #users[user.email].sessionCount--
