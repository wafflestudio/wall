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
    @chatInput.textareaAutoExpand()
    @connectionId = -1
    @status = "DISCONNECTED"
    

  toggle: -> @chatWindow.fadeToggle()

  sendMessage: =>
      msg = @chatInput.val()
      #msg = msg.substr(0, msg.length - 1) if msg.charAt(msg.length - 1) is '\n'
      @chatInput.val("")
      @socket.send JSON.stringify({connectionId:@connectionId, text: msg})

  onReceive: (e) =>
      data = JSON.parse(e.data)
      console.log data

      if data.error
        console.log('disconnected: ' + data.error)
        @socket.close()
        return

      switch data.kind
        when "welcome"
          @setUsers(data.users)

          if @status == "DISCONNECTED"
            @connectionId = data.connectionId
            console.log('connected with connection id ' + @connectionId)
            # now sending message is available
            @chatInput.on 'keydown', (event) =>
              if event.keyCode is 13 and !event.shiftKey and @chatInput.val().replace(/\s/g, '').length > 0
                @sendMessage()

          @status = "CONNECTED"

        when "join"
          if not @users[data.username]?
            @users[data.username] = {username: data.username, nickname: data.nickname, picture: data.picture}
            newMessage = @infoMaker(data.nickname, "has joined")
          if @status == "CONNECTED"
            @users[data.username]?.sessionCount ++
        when "quit"
          @users[data.username]?.sessionCount --
          if @users[data.username]?.sessionCount is 0
            newMessage = @infoMaker(@users[data.username].nickname, " has left") 
          
        when "talk" then newMessage = @messageMaker(@users[data.username], data.message)
        
      @chatLog.append newMessage if newMessage?
      @chatLog.animate {scrollTop : @chatLog.prop('scrollHeight') - @chatLog.height()}, 150
  
  onError: (e) ->
    # TODO: add reconnection
    console.log(e)

  setUsers: (users) ->
    # clear all existing users
    @users = {}
    @userList.html('')
    for user in users
      @users[user.email] ||= user
      @users[user.email].sessionCount ||= 0
      @users[user.email].sessionCount ++

  userJoin: (user) ->
    user.sessionCount = 0
    @users[user.email] = user unless @users[user.email]?
    @users[user.email].sessionCount++

  addUser: (user) ->
    @userList.append $("<div class = 'chatProfilePic' style = 'background-image:url(#{user.picture})'> </div>")

  messageMaker: (user, message) ->
    owner = if user?.email is stage.currentUser then "isMine" else "isNotMine"
    $("<div class = 'messageContainer'>
        <div class = 'messageDiv #{owner}'>
          <div class = 'messageProfilePicContainer'>
            <div class = 'messageProfilePic' style = 'background-image:url(#{user?.picture ? ""})'></div>
          </div>
          <div class = 'messageRest'>
            <div class = 'messageNickname'>#{user?.nickname ? "???"}</div>
            <span class = 'messageText'>#{message}</span>
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
